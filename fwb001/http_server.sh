#!/usr/bin/env bash
set -e
trap handle_exit ERR EXIT

# This bash script is our rudimentary http server. We will initially implement support for only
# GET and POST methods of the HTTP application layer protocol (v1.1). We will use ncat to handle TCP/IP
# network communication, and this script will essentially interpret and appropriately respond to
# HTTP requests. We will enhance it in future chapters.
#
# To start the server, use this command from the within the same directory as this script:
# ncat -lk -p 7777 --sh-exec "./http_server.sh"


#
# globals
#
DEBUG=true
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
function handle_exit {
  if [[ $? -ne 0 ]]; then
    http_response 500 "Internal Server Error" "text/html"
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

# Sends back http status line and headers. Echo the response payload after calling this function.
function http_response {
  local http_status_code=$1
  local http_status_msg=$2
  local content_type=$3

  # send the status line
  echo "HTTP/1.1 $http_status_code $http_status_msg"

  # send headers
  echo "Content-Type: $content_type"
  echo "Server: funwithbash"
  echo ''
}

# Parse the HTTP request and populate the HTTP globals
function http_request() {
  # read the raw request line
  read -r raw

  # strip trailing CR
  raw=${raw%%$'\r'}
  log_debug "$raw"

  # now parse the request line
  read -r HTTP_REQUEST_METHOD HTTP_REQUEST_URI HTTP_REQUEST_HTTP_VERSION <<< "$raw"

  # separate out any query params from the URI
  read -r HTTP_REQUEST_URI HTTP_REQUEST_QUERY_PARAMS <<< $(echo $HTTP_REQUEST_URI | tr "?" " ")

  # read all the following lines in a loop till end of headers
  while read -r raw; do
    raw=${raw%%$'\r'}

    # if POST request, parse the Content-Length
    if [[ "$HTTP_REQUEST_METHOD" == "POST" ]]; then
        if [[ "$raw" == "Content-Length: "** ]]; then
            HTTP_REQUEST_LENGTH="$(sed 's/Content-Length: //' <<< $raw)"
            if [[ -z "${HTTP_REQUEST_LENGTH}" ]]; then
              exit 1
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
  if [[ "$HTTP_REQUEST_METHOD" == "POST" ]]; then
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
# main script
#

# parse the incoming request
http_request

# for now send a placeholder response back
http_response 200 "OK" "text/html"
echo "Have fun with bash!"
