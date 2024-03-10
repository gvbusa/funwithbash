#!/usr/bin/env bash

# deploy given version of given app to given environment, e.g.:
# ./deploy.sh fwb-task-list 1.0.0 dev

# arguments
if [[ $# -ne 3 ]]; then
  echo "Not enough arguments. Usage: ./deploy.sh <app> <version> <environment>"
  exit 1
fi
export APP=$1
export VERSION=$2
export ENVIRONMENT=$3

# get the TARGET IP Address from the APP-ENVIRONMENT cloudformation stack
export TARGET=$(aws cloudformation describe-stacks --stack-name ${APP}-${ENVIRONMENT} | jq -r '.Stacks[].Outputs[].OutputValue')

# secrets location
SECRETS=../.secrets/${ENVIRONMENT}

# pem file location for scp and ssh commands
PEM_FILE=${SECRETS}/${APP}-${ENVIRONMENT}.pem

# fetch secrets and copy them to target
scp -i ${PEM_FILE} ${SECRETS}/.env ec2-user@"${TARGET}":.env
scp -i ${PEM_FILE} ${SECRETS}/ssl/* ec2-user@"${TARGET}":ssl/

# generate nginx.conf from template and copy it to target
j2 ./templates/nginx.j2.conf ./environments/${ENVIRONMENT}.yaml > ./.generated/nginx-${ENVIRONMENT}.conf
scp -i ${PEM_FILE} ./.generated/nginx-${ENVIRONMENT}.conf ec2-user@"${TARGET}":nginx/nginx.conf

# generate docker-compose.j2.yaml from template and copy it to target
j2 ./templates/docker-compose.j2.yaml > ./.generated/docker-compose.yaml
scp -i ${PEM_FILE} ./.generated/docker-compose.yaml ec2-user@"${TARGET}":docker-compose.yaml

# get docker credentials from .env
DOCKER_USER=$(cat ${SECRETS}/.env | grep "DOCKER_USER" | awk -F'=' '{print $2}')
DOCKER_TOKEN=$(cat ${SECRETS}/.env | grep "DOCKER_TOKEN" | awk -F'=' '{print $2}')

# go to the target machine and execute commands
ssh -i ${PEM_FILE} ec2-user@"${TARGET}" /bin/bash << EOF
echo "${DOCKER_TOKEN}" | docker login -u ${DOCKER_USER} --password-stdin
docker-compose down
nohup docker-compose up >out.log 2>err.log &
EOF

