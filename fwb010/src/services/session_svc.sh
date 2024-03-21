#!/usr/bin/env bash

# session micro-service

#globals
USER_EMAIL=""

#
# functions
#

function create_session() {
  local email=$1

  # delete any existing sessions for email
  local result=$(delete_many_by_filter "sessions" '{email: "'${email}'"}')
  handle_db_errors "${result}"

  # add session
  result=$(add_one "sessions" '{email: "'${email}'"}')
  handle_db_errors "${result}"
  echo "${result}"
}

function delete_session() {
  local email=$1
  # check if session exists for user
  local result=$(get_one_by_filter "sessions" '{email: "'${email}'"}')
  handle_db_errors "${result}"

  # delete session
  local id=$(echo "${result}" | jq -r '._id')
  local result=$(delete_one "sessions" "${id}")
  handle_db_errors "${result}"
  echo "${result}"
}

function authenticate() {
  # get auth token
  local token=""
  for hdr in "${HTTP_REQUEST_HEADERS[@]}"; do
    if [[ "${hdr}" == Authorization* ]] || [[ "${hdr}" == authorization* ]]; then
      token=$(echo "${hdr}" | awk -F': ' '{print $2}')
    fi
  done

  # no token
  if [[ -z "${token}" ]]; then
    send_http_response 401 "Unauthorized" "application/json" '{"error": "Unauthorized"}'
    exit 1
  fi

  # lookup token in sessions

  local result=$(get_one "sessions" "${token}")
  if [[ "${result}" == {* ]]; then
    USER_EMAIL=$(echo "${result}" | jq -r '.email')
    return
  else
    send_http_response 401 "Unauthorized" "application/json" '{"error": "Unauthorized"}'
    exit 1
  fi
}