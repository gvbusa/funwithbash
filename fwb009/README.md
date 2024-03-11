# Deploy task-list app to "dev" environment provisioned earlier
In the previous chapter we provisioned a "dev" environment in AWS.

In this chapter we will provision an EC2 instance in the "dev"
environment in which to deploy the task-list app. On the EC2 Instance we will
install docker and docker-compose, and start the docker service. We will 
then deploy the task-list app and the nginx reverse-proxy to it.

### Secrets Management
There are several secrets that are involved with this exercise. For
each app and environment being deployed to, we need to store
a set of secrets. At this time we will work with secrets that
are stored on your local machine, but definitely not checked in
to source control. Later in our journey we will use AWS Secrets Manager.

No secrets should accidentally or ignorantly
make their way into GitHub or Docker container images!


