#!/usr/bin/env bash

# create a self-signed cert which we will configure into our nginx reverse-proxy

rm -rf etc
mkdir -p etc/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -subj "/C=US/ST=IL/L=Chicago/O=Home/CN=*.funwithbash.com" \
  -keyout etc/ssl/nginx-selfsigned.key \
  -out etc/ssl/nginx-selfsigned.crt

