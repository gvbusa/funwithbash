#!/usr/bin/env bash

# email micro-service

#
# functions
#

function send_email() {
  local to=$1
  local subject=$2
  local msg=$3

  local data='{"personalizations": [{"to": [{"email": "'${to}'"}]}],"from": {"email": "team@funwithbash.com"},"subject": "'${subject}'","content": [{"type": "text/plain", "value": "'${msg}'"}]}'

  curl -s --request POST \
    --url https://api.sendgrid.com/v3/mail/send \
    --header "Authorization: Bearer ${SENDGRID_API_KEY}" \
    --header 'Content-Type: application/json' \
    --data "${data}"
}
