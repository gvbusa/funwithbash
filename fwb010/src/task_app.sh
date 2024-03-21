#!/usr/bin/env bash

#set -x

# task web app
# to run it use ./start_server.sh

# imports
source "./common/http_server.sh"
source "./common/router.sh"
source "./common/db_mongo.sh"

source "./services/task_svc.sh"
source "./services/session_svc.sh"
source "./services/user_svc.sh"
source "./services/email_svc.sh"

# route
route


