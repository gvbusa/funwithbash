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

# create .generated directory
mkdir -p .generated

# get vpc_id and subnet_id from environment stack
export VPC_ID=$(aws cloudformation describe-stacks --stack-name env-${ENVIRONMENT} | jq -r '.Stacks[].Outputs[].OutputValue' | grep vpc)
export SUBNET_ID=$(aws cloudformation describe-stacks --stack-name env-${ENVIRONMENT} | jq -r '.Stacks[].Outputs[].OutputValue' | grep subnet)


# generate stack from template
j2 ./templates/compute.j2.yaml ./environments/${ENVIRONMENT}.yaml > ./.generated/${APP}-${ENVIRONMENT}.yaml

# deploy the stack
aws cloudformation deploy --template-file ./.generated/${APP}-${ENVIRONMENT}.yaml --stack-name ${APP}-${ENVIRONMENT}
