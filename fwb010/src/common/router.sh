#!/usr/bin/env bash

# globals
ROUTES=()
USER_EMAIL=""

function add_route {
  method=$1
  regex=$2
  function=$3

  ROUTES+=("${method}|${regex}|${function}|auth")
}

function add_route_anon {
  method=$1
  regex=$2
  function=$3

  ROUTES+=("${method}|${regex}|${function}|anon")
}

function route {
  # parse request
  parse_http_request

  # do matching
  local method_match=no
  local uri_match=no
  for route in "${ROUTES[@]}"; do
    local method=$(echo ${route} | awk -F'|' '{print $1}')
    local regex=$(echo ${route} | awk -F'|' '{print $2}')
    local function=$(echo ${route} | awk -F'|' '{print $3}')
    local route_type=$(echo ${route} | awk -F'|' '{print $4}')
    if [[ ${HTTP_REQUEST_URI} =~ ${regex} ]]; then
      uri_match=yes
      if [[ ${HTTP_REQUEST_METHOD} == ${method} ]]; then
        method_match=yes
        if [[ "${route_type}" == "auth" ]]; then
          authenticate
        fi
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

#
# functions to handle serving static content
#

function handle_index_html() {
  send_http_file "./web/index.html"
}

function handle_static_content() {
  # if file exists, then send back file content
  if [[ -f ".${HTTP_REQUEST_URI}" ]]; then
    send_http_file ".${HTTP_REQUEST_URI}"
  else
    send_http_response "404" "Not Found" "text/html"
  fi
}

add_route_anon 'GET' '^$' 'handle_index_html'
add_route_anon 'GET' '^/$' 'handle_index_html'
add_route_anon 'GET' '^/web/(.+)$' 'handle_static_content'
