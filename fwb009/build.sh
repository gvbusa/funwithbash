#!/usr/bin/env bash

# build docker images and push them to private docker registry
# should have first logged in to docker registry using "docker login -u <username>"

docker build -t gvbusa/fwb-task-list:1.0.0 .
docker push gvbusa/fwb-task-list:1.0.0
