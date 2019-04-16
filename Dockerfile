ARG BUILD_IMAGE=geoffreybooth/meteor-base:1.8.0.2
ARG RUNTIME_IMAGE=rocketchat/base:8
FROM $BUILD_IMAGE

ARG GIT_REPO=https://github.com/RocketChat/Rocket.Chat.git
ARG GIT_BRANCH=develop
ARG GIT_COMMIT=HEAD

RUN apt-get update && apt-get install --assume-yes git vim

WORKDIR $APP_SOURCE_FOLDER/

RUN printf "\n[-] Cloning branch $GIT_BRANCH from repo $GIT_REPO \n\n" \
&&  git clone --single-branch -b $GIT_BRANCH $GIT_REPO $APP_SOURCE_FOLDER/ \
&&  git reset --hard $GIT_COMMIT

RUN printf "\n[-] Installing app NPM dependencies...\n\n" \
&&  cd $APP_SOURCE_FOLDER \
&&  meteor npm install

RUN printf "\n[-] Building Meteor application bundle...\n\n" \
&&  mkdir --parents $APP_BUNDLE_FOLDER

ENV METEOR_PROFILE=100
ENV METEOR_DEBUG_BUILD=1

RUN TOOL_NODE_FLAGS="--max-old-space-size=4096 --optimize_for_size --gc-interval=100" meteor build --directory $APP_BUNDLE_FOLDER --server-only

RUN rm -rf $SCRIPTS_FOLDER/node_modules

FROM $RUNTIME_IMAGE

LABEL maintainer="peyman.aparviz@redlink.co"

ENV APP_BUNDLE_FOLDER /opt/bundle
ENV SCRIPTS_FOLDER /docker

VOLUME $APP_BUNDLE_FOLDER/uploads

# Copy in entrypoint
COPY --from=0 --chown=rocketchat:rocketchat $SCRIPTS_FOLDER $SCRIPTS_FOLDER/
RUN cd $SCRIPTS_FOLDER/ \
&&  npm install

# Copy in app bundle
COPY --from=0 --chown=rocketchat:rocketchat $APP_BUNDLE_FOLDER/bundle $APP_BUNDLE_FOLDER/bundle/

RUN mkdir -p $APP_BUNDLE_FOLDER/uploads \
&&  chown rocketchat:rocketchat $APP_BUNDLE_FOLDER/uploads \
&&  chown -R rocketchat:rocketchat $SCRIPTS_FOLDER/

RUN printf "\n[-] Installing Meteor application server NPM dependencies...\n\n" \
&&  cd $APP_BUNDLE_FOLDER/bundle/programs/server/ \
&&  npm install \
&&  npm cache clear --force

USER rocketchat

WORKDIR $APP_BUNDLE_FOLDER/bundle

EXPOSE 3000

# needs a mongoinstance - defaults to container linking with alias 'mongo'
ENV DEPLOY_METHOD=docker \
    NODE_ENV=production \
    MONGO_URL=mongodb://mongo:27017/rocketchat \
    HOME=/tmp \
    PORT=3000 \
    ROOT_URL=http://localhost:3000 \
    Accounts_AvatarStorePath=$APP_BUNDLE_FOLDER/uploads \
    Debug_Level=debug

# Start app
ENTRYPOINT ["/docker/entrypoint.sh"]

CMD ["node", "main.js"]
