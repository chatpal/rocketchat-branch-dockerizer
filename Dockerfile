FROM geoffreybooth/meteor-base:1.8.0.2

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
&&  mkdir --parents $APP_BUNDLE_FOLDER \
&&  cd $APP_SOURCE_FOLDER \
&&  meteor build --directory $APP_BUNDLE_FOLDER --server-only

FROM debian:jessie-slim

LABEL maintainer="peyman.aparviz@redlink.co"

RUN gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys DD8F2338BAE7501E3DD5AC78C273792F7D83545D
ENV NODE_VERSION 8.11.4
ENV NODE_ENV production
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends ca-certificates curl; \
	rm -rf /var/lib/apt/lists/*; \
	curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz"; \
	curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc"; \
	gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc; \
	grep " node-v$NODE_VERSION-linux-x64.tar.gz\$" SHASUMS256.txt | sha256sum -c -; \
	tar -xf "node-v$NODE_VERSION-linux-x64.tar.gz" -C /usr/local --strip-components=1 --no-same-owner; \
	rm "node-v$NODE_VERSION-linux-x64.tar.gz" SHASUMS256.txt.asc SHASUMS256.txt; \
	npm cache clear --force

ENV APP_BUNDLE_FOLDER /opt/bundle
ENV SCRIPTS_FOLDER /docker

RUN groupadd -r rocketchat \
&&  useradd -r -g rocketchat rocketchat

VOLUME $APP_BUNDLE_FOLDER/uploads

# Copy in entrypoint
COPY --from=0 --chown=rocketchat:rocketchat $SCRIPTS_FOLDER $SCRIPTS_FOLDER/

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
    MONGO_OPLOG_URL=mongodb://mongo:27017/local \
    HOME=/tmp \
    PORT=3000 \
    ROOT_URL=http://localhost:3000 \
    Accounts_AvatarStorePath=$APP_BUNDLE_FOLDER/uploads \
    Debug_Level=debug

# Start app
ENTRYPOINT ["/docker/entrypoint.sh"]

CMD ["node", "main.js"]
