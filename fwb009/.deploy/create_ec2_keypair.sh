#!/usr/bin/env bash

# create a EC2 key-pair and save private key PEM file to .secrets
# ./create_ec2_keypair.sh <app> <environment>

# arguments
if [[ $# -ne 2 ]]; then
  echo "Not enough arguments. Usage: ./create_ec2_keypair.sh <app> <environment>"
  exit 1
fi
APP=$1
ENVIRONMENT=$2

# secrets location
SECRETS=../.secrets/${ENVIRONMENT}

# create key pair
aws ec2 create-key-pair --key-name ${APP}-${ENVIRONMENT} --query "KeyMaterial" --output text > ${SECRETS}/${APP}-${ENVIRONMENT}.pem
chmod 400 ${SECRETS}/${APP}-${ENVIRONMENT}.pem
