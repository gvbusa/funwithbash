#!/usr/bin/env bash

# create an environment shared by teams
# ./provision.sh dev

# arguments
if [[ $# -ne 1 ]]; then
  echo "Not enough arguments. Usage: ./provision.sh <environment>"
  exit 1
fi
ENVIRONMENT=$1

# create .generated directory
mkdir -p .generated

# generate stack from template
j2 ./templates/env.j2.yaml ./environments/${ENVIRONMENT}.yaml > ./stacks/env-${ENVIRONMENT}.yaml

# deploy the stack
aws cloudformation deploy --template-file ./stacks/env-${ENVIRONMENT}.yaml --stack-name env-${ENVIRONMENT}
