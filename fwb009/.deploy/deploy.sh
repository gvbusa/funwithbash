#!/usr/bin/env bash

# deploy given version of given app to given environment, e.g.:
# ./deploy.sh fwb-task-list 1.0.0 dev

# for now
TARGET="3.95.100.155"

# arguments
if [[ $# -ne 3 ]]; then
  echo "Not enough arguments. Usage: ./deploy.sh <app> <version> <environment>"
  exit 1
fi
export APP=$1
export VERSION=$2
export ENVIRONMENT=$3


# fetch secrets and copy them to target
scp -i ~/.ssh/fwb-dev.pem ../../.env ec2-user@"${TARGET}":.env
scp -i ~/.ssh/fwb-dev.pem ../../fwb007/etc/ssl/* ec2-user@"${TARGET}":ssl/

# generate nginx.conf from template and copy it to target
j2 ./templates/nginx.j2.conf ./environments/${ENVIRONMENT}.yaml > ./stacks/nginx.conf
scp -i ~/.ssh/fwb-dev.pem ./stacks/nginx.conf ec2-user@"${TARGET}":nginx/nginx.conf

# generate docker-compose.j2.yaml from template and copy it to target
j2 ./templates/docker-compose.j2.yaml > ./stacks/docker-compose.yaml
scp -i ~/.ssh/fwb-dev.pem ./stacks/docker-compose.yaml ec2-user@"${TARGET}":docker-compose.yaml

# go to the target machine and execute commands
ssh -i ~/.ssh/fwb-dev.pem ec2-user@"${TARGET}" /bin/bash << EOF
docker-compose down
nohup docker-compose up >out.log 2>err.log &
EOF

