# Rocket.Chat Branch Dockerizer

## Build Preparation

* Copy `docker-compose.override.yml.sample` to `docker-compose.override.yml` and adjust it according to your needs.  
  You can override any parameter that is defined in `docker-compose.yml` or add new parameters.  
  (Note that multi-valued parameters (like `ports`) are concatenated.)


## Build

* Run `docker-compose build rocketchat` to build the Rocket.Chat image


## Run

* Rocket.Chat requires a MongoDB instance.  
  You can start an instance by running `docker-compose up -d mongo`.  
  After first run, you can create a replica by running `docker-compose up -d mongo-init-replica`.
* Start Rocket.Chat: `docker-compose up -d rocketchat`

For more info see: https://rocket.chat/docs/installation/docker-containers/docker-compose/
