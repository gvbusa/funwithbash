FROM arm64v8/debian:latest

# install dependencies
RUN apt-get update && apt-get install -y procps file util-linux wget curl ncat jq && \
    wget https://downloads.mongodb.com/compass/mongosh-2.1.5-linux-arm64.tgz \
    && tar -zxvf mongosh-2.1.5-linux-arm64.tgz \
    && cp mongosh-2.1.5-linux-arm64/bin/mongosh /usr/local/bin \
    && cp mongosh-2.1.5-linux-arm64/bin/mongosh_crypt_v1.so /usr/local/bin

# add code
ADD src/ /

# expose port
EXPOSE 7777

# entrypoint
ENTRYPOINT ["/bin/bash", "-c", "./start_server.sh"]
