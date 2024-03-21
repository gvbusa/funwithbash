#!/usr/bin/env bash

# create a self-signed cert which we will configure into our nginx reverse-proxy
# ./create_selfsigned_cert.sh <environment>

# arguments
if [[ $# -ne 1 ]]; then
  echo "Not enough arguments. Usage: ./create_selfsigned_cert.sh <environment>"
  exit 1
fi
ENVIRONMENT=$1

# secrets location
SECRETS=../.secrets/${ENVIRONMENT}

rm -rf ${SECRETS}/ssl
mkdir -p ${SECRETS}/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=US/ST=IL/L=Chicago/O=Home/CN=*.funwithbash.com" \
  -keyout ${SECRETS}/ssl/nginx-selfsigned.key \
  -out ${SECRETS}/ssl/nginx-selfsigned.crt

