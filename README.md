# Rocket.Chat Branch Dockerizer

## Build Preparation

* Copy `docker-compose.override.yml.sample` to `docker-compose.override.yml` and adjust it according to your needs.
  You can override any parameter that is defined in `docker-compose.yml` or add new parameters.  
  (Note that multi-valued parameters (like `ports`) will be concatenated)


## Build

* To build the Rocket.Chat image run: 
  ```
  docker-compose build rocketchat
  ```

## Run

* Rocket.Chat requires a MongoDB instance.  
  You can start an instance by running: 
  ```
  docker-compose up -d mongo
  ```
  After first run, you can create a replica by running: 
  ```
  docker-compose up -d mongo-init-replica
  ```
* Start Rocket.Chat: 
  ```
  docker-compose up -d rocketchat
  ```
* A Chatpal standalone instance is automatically started.
  To use this instance you can point your chatpal-search provider to: `http://chatpal-search:8983/solr/chatpal`

For more info see: https://rocket.chat/docs/installation/docker-containers/docker-compose/
