#!/usr/bin/env bash

# create a self-signed cert which we will configure into our nginx reverse-proxy

rm -rf etc
mkdir -p etc/ssl/private
mkdir -p etc/ssl/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout etc/ssl/private/nginx-selfsigned.key \
  -out etc/ssl/certs/nginx-selfsigned.crt

