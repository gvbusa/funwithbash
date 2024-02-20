#!/usr/bin/env bash

# test http_server.sh
# ncat --listen --keep-open --source-port 7777 --sh-exec "./test_http_server.sh"

# imports
source "./http_server.sh"

# parse the incoming request
parse_http_request

# for now send a placeholder response back
send_http_response 200 "OK" "text/html" "Have fun with bash!"




