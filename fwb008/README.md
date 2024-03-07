# Create an environment in AWS to deploy the task-list app
In this chapter we use AWS Cloudformation to create a "dev" environment.
We use jinja2 templating to create the templates/env.j2.yaml which
contains Cloudformation resources and outputs, with jinja2 
templating to handle environment-specific variations.

For each environment, we maintain the environments/<env>.yaml file
of values to be used for template processing.

The provision.sh script can be run for a given environment. It
processes the template to generate the stack for the given environment
and then does a "aws cloudformation deploy" to create or update the stack

The only outputs are the VpcId and SubnetId in which EC2 compute instances 
will be spun up for the applications being deployed to that
environment.


