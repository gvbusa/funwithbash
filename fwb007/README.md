# Add a nginx reverse-proxy for the task-list web app
Before we can deploy our task-list web app, we will need
to support HTTPS access using an SSL certificate. We will 
accomplish this by doing the following:

- Create a self-signed SSL certificate
- Create an nginx configuration that
  - allows only HTTPS traffic, permanently redirecting HTTP traffic to HTTPS
  - forwards requests to the upstream task-list web app running on the same server as nginx
- Run nginx in its own docker container
