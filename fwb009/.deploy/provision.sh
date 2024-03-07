#!/usr/bin/env bash

# provision compute instance(s) for given app in given environment
# ./provision.sh dev

# arguments
if [[ $# -ne 2 ]]; then
  echo "Not enough arguments. Usage: ./provision.sh <app> <environment>"
  exit 1
fi
APP=$1
ENVIRONMENT=$2

# generate stack from template
j2 ./templates/compute.j2.yaml ./environments/${ENVIRONMENT}.yaml > ./stacks/${APP}-${ENVIRONMENT}.yaml

# deploy the stack
aws cloudformation deploy --template-file ./stacks/${APP}-${ENVIRONMENT}.yaml --stack-name ${APP}-${ENVIRONMENT}
