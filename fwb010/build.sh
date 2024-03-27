#!/usr/bin/env bash

# build docker images and push them to private docker repository
# should have first logged in to docker registry using "docker login -u <username>"
# ./build.sh <repo> <version>

# arguments
if [[ $# -ne 2 ]]; then
  echo "Not enough arguments. Usage: ./build.sh <repo> <version>"
  exit 1
fi
REPO=$1
VERSION=$2

docker build -t ${REPO}:${VERSION} .
docker push ${REPO}:${VERSION}
