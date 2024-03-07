# Add a nginx reverse-proxy for the task-list web app
Before we can deploy our task-list web app, we will need
to support HTTPS access using an SSL certificate. We will 
accomplish this by doing the following:

- Create a self-signed SSL certificate
- Create an nginx configuration that
  - allows only HTTPS traffic, permanently redirecting HTTP traffic to HTTPS
  - forwards requests to the upstream task-list web app running on the same server as nginx
- Create a docker-compose configuration that starts the web app and nginx

Before running the container, create a .env file in the root directory of the repository
that contains the 3 environment variables for MongoDB:

    MONGO_USER=<user>
    MONGO_PASSWORD=<password>
    MONGO_URI=mongodb+srv://<cluster>/<db>

compose.yml is the docker-compose configuration, and the
containers can be run with:

    docker-compose up

To shutdown:

    docker-compose down

The nginx configuration and SSL key and certificate are 
made available to the nginx container by means of volume mapping.
