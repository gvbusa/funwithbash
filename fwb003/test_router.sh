#!/usr/bin/env bash

# test router.sh
# ncat --listen --keep-open --source-port 7777 --sh-exec "./test_router.sh"

# imports
source "../fwb001/http_server.sh"
source "./router.sh"

#
# functions
#
function handle_get_all_tasks() {
  log_info "handle_get_all_tasks() called"
  send_http_response 200 "OK" "application/json" '[]'
}

# add a route
add_route 'GET' '^/task$' 'handle_get_all_tasks'

# route
route


