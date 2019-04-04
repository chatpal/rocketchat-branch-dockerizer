# Rocket.Chat Branch Dockerizer

## Build Preparation

  Copy `docker-compose.override.yml.sample` to `docker-compose.override.yml` and adjust it according to your needs.
  You can override any parameter that is defined in `docker-compose.yml` or add new parameters.
  (Note that multi-valued parameters (like `ports`) will be concatenated)
  Some important parameters to mention:
  * Meteor version can be changed by changing the `BUILD_IMAGE` build argument of the `rocketchat` service. 
  * Runtime image can be changed using the `RUNTIME_IMAGE` build argument of the `rocketchat` service. 
  * Mongo image version can be changed for both `mongo` and `mongo-init-replica` services. 

## Build

  To build the Rocket.Chat image run: 
  ```
  docker-compose build rocketchat
  ```

## Run
  * You can star Rocket.Chat by running:
  ```bash
  docker-compose up -d rocketchat
  ```
  * A Chatpal standalone instance is automatically started.
  To use this instance you can point your chatpal-search provider to: `http://chatpal-search:8983/solr/chatpal`

### Production
  It is recommended to use a mongoDB replica to enable oplog tailing so meteor can be notified of realtime changes in the DB.
  * Add the following environment variable to the `environment` parameter of the `rocketchat` service in your `docker-compose.override.yml`.
  ```bash
  MONGO_OPLOG_URL=mongodb://mongo:27017/local
  ```
  * The command for mongo service needs to be changed. Add this to your yaml file:
  ```bash
  command: mongod --smallfiles --oplogSize 128 --replSet rs0 --storageEngine=mmapv1
  ```
  After running mongoDB for the first time you can initialize the replica.
  * Start mongo manually by running: 
  ```bash
  docker-compose up -d mongo
  ```
  * Initialize the replica: 
  ```bash
  docker-compose up -d mongo-init-replica
  ```
  * Start Rocket.Chat: 
  ```bash
  docker-compose up -d rocketchat
  ```
  From now on you will only need to run the last command as long as the mongo container exists.
  
For more information refer to: https://rocket.chat/docs/installation/docker-containers/docker-compose/
