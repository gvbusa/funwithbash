# Containerize the web app
We will now build a docker image that packages the frontend and backend code.

    docker build -t fwb-task-list-app:1.0.0 .

Before running the container, create a .env file in the root directory of the repository
that contains the 3 environment variables for MongoDB:

    MONGO_USER=<user>
    MONGO_PASSWORD=<password>
    MONGO_URI=mongodb+srv://<cluster>/<db>

compose.yml is the docker-compose configuration, and the 
container can be run with:

    docker-compose up

To shutdown:

    docker-compose down
