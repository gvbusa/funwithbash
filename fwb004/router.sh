#!/usr/bin/env bash

# globals
ROUTES=()

function add_route {
  method=$1
  regex=$2
  function=$3

  ROUTES+=("${method}|${regex}|${function}")
}

function route {
  # parse request
  parse_http_request

  # do matching
  local method_match=no
  local uri_match=no
  for route in "${ROUTES[@]}"; do
    method=$(echo ${route} | awk -F'|' '{print $1}')
    regex=$(echo ${route} | awk -F'|' '{print $2}')
    function=$(echo ${route} | awk -F'|' '{print $3}')
    if [[ ${HTTP_REQUEST_URI} =~ ${regex} ]]; then
      uri_match=yes
      if [[ ${HTTP_REQUEST_METHOD} == ${method} ]]; then
        method_match=yes
        $function
        exit $?
      fi
    fi
  done

  if [[ ${uri_match} == "no" ]]; then
    log_info "No matching route found for ${HTTP_REQUEST_METHOD} ${HTTP_REQUEST_URI}"
    send_http_response 404 "Not Found" "text/html"
  elif [[ ${method_match} == "no" ]]; then
    send_http_response 405 "Method Not Allowed" "text/html"
  fi
}

