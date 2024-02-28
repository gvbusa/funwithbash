#!/usr/bin/env bash

# task list micro-service

#
# functions
#
function handle_db_errors() {
  local result=$1
  if [[ "${result}" == [* ]] || [[ "${result}" == {* ]]; then
    return
  elif [[ -z "${result}" ]]; then
    send_http_response 500 "Internal Server Error" "text/html" '{"error": "Database request timed out"}'
    exit 1
  else
    send_http_response 404 "Not Found" "text/html" '{"error": "Resource not found"}'
    exit 1
  fi
}

function validate_task() {
  local payload=$1
  local name=$(echo "${payload}" | jq -r '.name')
  local notes=$(echo "${payload}" | jq -r '.notes')

  # name is required, not empty, and is xss protected
  if [[ "${name}" == "null" ]] || [[ -z "${name}" ]] || [[ "${name}" =~ [\<\>]+ ]]; then
    send_http_response 400 "Bad Request" "text/html" '{"error": "\"name\": cannot be empty and cannot contain < or > characters"}'
    exit 1
  fi

  # notes is required, can be empty, and if populated, is xss protected
  if [[ "${notes}" == "null" ]] || [[ "${notes}" =~ [\<\>]+ ]]; then
    send_http_response 400 "Bad Request" "text/html" '{"error": "\"notes\": cannot contain < or > characters"}'
    exit 1
  fi
}

function handle_get_all_tasks() {
  local result=$(get_all "tasks")
  handle_db_errors "${result}" || return
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_add_task() {
  validate_task "${HTTP_REQUEST_BODY}"
  local result=$(add_one "tasks" "${HTTP_REQUEST_BODY}")
  handle_db_errors "${result}"
  send_http_response 201 "Created" "application/json" "${result}"
}

function handle_update_task_by_id() {
  local id=${BASH_REMATCH[1]}
  # first ensure that doc with id exists
  local result=$(get_one "tasks" "${id}")
  handle_db_errors "${result}"

  # then validate the payload
  validate_task "${HTTP_REQUEST_BODY}"

  # now update it
  local result=$(update_one "tasks" "${id}" "${HTTP_REQUEST_BODY}")
  handle_db_errors "${result}"
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_get_task_by_id() {
  local id=${BASH_REMATCH[1]}
  local result=$(get_one "tasks" "${id}")
  handle_db_errors "${result}"
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_delete_task_by_id() {
  local id=${BASH_REMATCH[1]}

  # first ensure that doc with id exists
  local result=$(get_one "tasks" "${id}")
  handle_db_errors "${result}"

  local result=$(delete_one "tasks" "${id}")
  handle_db_errors "${result}"
  send_http_response 204 "No Content" "application/json" "${result}"
}

# add routes
add_route 'GET' '^/api/task$' 'handle_get_all_tasks'
add_route 'POST' '^/api/task$' 'handle_add_task'
add_route 'PUT' '^/api/task/(.+)$' 'handle_update_task_by_id'
add_route 'GET' '^/api/task/(.+)$' 'handle_get_task_by_id'
add_route 'DELETE' '^/api/task/(.+)$' 'handle_delete_task_by_id'
