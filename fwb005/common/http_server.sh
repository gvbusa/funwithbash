#!/usr/bin/env bash
set -e
trap handle_error ERR

# This bash script is our rudimentary http server. We will initially implement support for only
# GET, POST, and PUT methods of the HTTP application layer protocol (v1.1). We will use ncat to handle TCP/IP
# network communication, and this script will essentially interpret and appropriately respond to
# HTTP requests. We will enhance it in future chapters.
#
# To start the server, use this command from the within the same directory as this script:
# ncat -lk -p 7777 --sh-exec "./test_http_server.sh"
# Or to be more explicit:
# ncat --listen --keep-open --source-port 7777 --sh-exec "./test_http_server.sh"


#
# globals
#
DEBUG=false
HTTP_REQUEST_METHOD=""
HTTP_REQUEST_URI=""
HTTP_REQUEST_HTTP_VERSION=""
HTTP_REQUEST_QUERY_PARAMS=""
HTTP_REQUEST_BODY=""
HTTP_REQUEST_LENGTH=0
declare -a HTTP_REQUEST_HEADERS


#
# functions
#

# when script errors out
function handle_error {
  if [[ $? -ne 0 ]]; then
    send_http_response 500 "Internal Server Error" "text/html"
  fi
}

# logging
function log_info {
  echo "< $@" >&2
}

# logging if DEBUG is true
function log_debug {
  if [[ "${DEBUG}" == "true" ]]; then
    echo "< $@" >&2
  fi
}

# Sends back http status line and headers.
function send_http_response {
  local http_status_code=$1
  local http_status_msg=$2
  local content_type=$3
  local payload=$4

  # send the status line
  echo "HTTP/1.1 $http_status_code $http_status_msg"

  # send headers
  echo "Content-Type: $content_type"
  echo "Server: funwithbash"
  echo ''
  echo "${payload}"
}

# Parse the HTTP request and populate the HTTP globals
function parse_http_request() {
  # read the raw request line
  read -r raw

  # strip trailing CR
  raw=${raw%%$'\r'}
  log_info "$raw"

  # now parse the request line
  read -r HTTP_REQUEST_METHOD HTTP_REQUEST_URI HTTP_REQUEST_HTTP_VERSION <<< "$raw"

  # separate out any query params from the URI
  read -r HTTP_REQUEST_URI HTTP_REQUEST_QUERY_PARAMS <<< $(echo $HTTP_REQUEST_URI | tr "?" " ")

  # read all the following lines in a loop till end of headers
  while read -r raw; do
    raw=${raw%%$'\r'}

    # if POST request, parse the Content-Length
    if [[ "$HTTP_REQUEST_METHOD" == "POST" ]] || [[ "$HTTP_REQUEST_METHOD" == "PUT" ]]; then
        if [[ "$raw" == "Content-Length: "** ]]; then
            HTTP_REQUEST_LENGTH="$(sed 's/Content-Length: //' <<< $raw)"
            if [[ -z "${HTTP_REQUEST_LENGTH}" ]] || [[ "${HTTP_REQUEST_LENGTH}" == "0" ]]; then
              send_http_response 400 "Bad Request" "text/html"
              exit
            fi
        fi
    fi

    log_debug "$raw"

    # if we have reached the end of the headers, break out of the loop
    [ -z "$raw" ] && break

    # extract headers into an array
    HTTP_REQUEST_HEADERS+=("$raw")
  done

  # finally, if POST request, extract the request body
  if [[ "$HTTP_REQUEST_METHOD" == "POST" ]] || [[ "$HTTP_REQUEST_METHOD" == "PUT" ]]; then
    read -n$HTTP_REQUEST_LENGTH -r HTTP_REQUEST_BODY
  fi

  # log parsed information at debug level
  log_debug "HTTP_REQUEST_METHOD: ${HTTP_REQUEST_METHOD}"
  log_debug "HTTP_REQUEST_URI: ${HTTP_REQUEST_URI}"
  log_debug "HTTP_REQUEST_QUERY_PARAMS: ${HTTP_REQUEST_QUERY_PARAMS}"
  log_debug "HTTP_REQUEST_HEADERS: ${HTTP_REQUEST_HEADERS[@]}"
  log_debug "HTTP_REQUEST_CONTENT_LENGTH: ${HTTP_REQUEST_LENGTH}"
  log_debug "HTTP_REQUEST_BODY: ${HTTP_REQUEST_BODY}"
  log_debug ""
}

#
# functions for serving static files
#
function file_size() {
  local file=$1
  echo $(stat -f%z "${file}")
}

function file_mime() {
  local file=$1
  echo $(file --mime-type -b "${file}")
}

function send_http_file() {
  local file=$1
  # send the status line
  echo "HTTP/1.1 200 OK"

  # send headers
  echo "Content-Type: $(file_mime $file)"
  echo "Content-Length: $(file_size $file)"
  echo "Server: funwithbash"
  echo ''

  cat ${file} >&1
}

