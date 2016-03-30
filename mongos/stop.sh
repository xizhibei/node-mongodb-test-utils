#!/bin/bash

source ./env.sh

docker rm -f mongos
docker-compose -p $PROJECT_NAME down
