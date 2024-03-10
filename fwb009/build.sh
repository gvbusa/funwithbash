#!/usr/bin/env bash

# build docker images and push them to private docker registry
# should have first logged in to docker registry using "docker login -u <username>"
# ./build.sh <version>

# arguments
if [[ $# -ne 1 ]]; then
  echo "Not enough arguments. Usage: ./build.sh <version>"
  exit 1
fi
VERSION=$1

docker build -t gvbusa/fwb-task-list:${VERSION} .
docker push gvbusa/fwb-task-list:${VERSION}
