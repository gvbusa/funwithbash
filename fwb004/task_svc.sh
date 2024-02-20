#!/usr/bin/env bash

# task list micro-service
# ncat --listen --keep-open --source-port 7777 --sh-exec "./task_svc.sh"

# imports
source "./http_server.sh"
source "./router.sh"
source "./db_mongo.sh"

#
# functions
#
function handle_get_all_tasks() {
  local result=$(get_all "tasks")
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_add_task() {
  local result=$(add_one "tasks" "${HTTP_REQUEST_BODY}")
  send_http_response 201 "Created" "application/json" "${result}"
}

function handle_update_task_by_id() {
  local id=${BASH_REMATCH[1]}
  local result=$(update_one "tasks" "${id}" "${HTTP_REQUEST_BODY}")
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_get_task_by_id() {
  local id=${BASH_REMATCH[1]}
  local result=$(get_one "tasks" "${id}")
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_delete_task_by_id() {
  local id=${BASH_REMATCH[1]}
  local result=$(delete_one "tasks" "${id}")
  send_http_response 204 "No Content" "application/json" "${result}"
}

# add routes
add_route 'GET' '^/task$' 'handle_get_all_tasks'
add_route 'POST' '^/task$' 'handle_add_task'
add_route 'PUT' '^/task/(.+)$' 'handle_update_task_by_id'
add_route 'GET' '^/task/(.+)$' 'handle_get_task_by_id'
add_route 'DELETE' '^/task/(.+)$' 'handle_delete_task_by_id'

# route
route


