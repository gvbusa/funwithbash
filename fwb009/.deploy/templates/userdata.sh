#!/bin/bash
# runs after ec2 instance boots up
# installs docker and docker-compose, starts docker service

yum update

# install docker and allow ec2-user to run it
yum install -y docker
usermod -a -G docker ec2-user
id ec2-user
newgrp docker

# start docker service
systemctl enable docker.service
systemctl start docker.service

# install docker-compose
yum install -y python3-pip
pip3 install docker-compose==1.28.0

# create directories for nginx files
mkdir -p nginx
mkdir -p ssl

# chown to ec2-user
chown ec2-user:ec2-user nginx
chown ec2-user:ec2-user ssl
