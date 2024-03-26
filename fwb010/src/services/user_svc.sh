#!/usr/bin/env bash

# user micro-service

#
# address platform-specific behavior of shasum256 and md5 commands
#
if [[ "${OSTYPE}" == darwin* ]]; then
  SHASUM256_CMD="shasum -a 256"
  MD5_CMD="md5"
else
  SHASUM256_CMD="sha256sum"
  MD5_CMD="md5sum"
fi


#
# functions
#

function validate_user() {
  local payload=$1
  local email=$(echo "${payload}" | jq -r '.email')
  local password=$(echo "${payload}" | jq -r '.password')

  # email is required, not empty, and is xss protected
  if [[ "${email}" == "null" ]] || [[ -z "${email}" ]] || [[ "${email}" =~ [\<\>]+ ]]; then
    send_http_response 400 "Bad Request" "text/html" '{"error": "\"email\": cannot be empty and cannot contain < or > characters"}'
    exit 1
  fi

  # password is required, not empty, and is xss protected
  if [[ "${password}" == "null" ]]  || [[ -z "${password}" ]] || [[ "${password}" =~ [\<\>]+ ]]; then
    send_http_response 400 "Bad Request" "text/html" '{"error": "\"password\": cannot be empty and cannot contain < or > characters"}'
    exit 1
  fi
}

function handle_login_user() {
  validate_user "${HTTP_REQUEST_BODY}"

  local email=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.email')
  local password=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.password')
  local sha256=$(echo -n "$password" | ${SHASUM256_CMD} | awk -F' ' '{print $1}')

  # email
  local result=$(get_one_by_filter "users" '{email: "'${email}'"}')
  if [[ "${result}" != {* ]]; then
    send_http_response 401 "Unauthorized" "application/json" '{"error": "Incorrect email or password"}'
    exit 1
  fi

  # password
  local db_password=$(echo "${result}" | jq -r '.password')

  if [[ "${sha256}" == "${db_password}" ]]; then
    result=$(create_session "${email}")
    response=$(echo "${result}" | jq -c '.email = "'${email}'"')
    send_http_response 200 "OK" "application/json" "${response}"
  else
    send_http_response 401 "Unauthorized" "application/json" '{"error": "Incorrect email or password"}'
  fi
}

function handle_logout_user() {
  local email=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.email')
  local result=$(delete_session "${email}")
  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_auth_valid() {
  send_http_response 200 "OK" "application/json" '{"email": "'${USER_EMAIL}'"}'
}

function handle_signup_user() {
  validate_user "${HTTP_REQUEST_BODY}"
  local email=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.email')

  # first check if user already signed up
  local result=$(get_one_by_filter "users" '{email: "'${email}'"}')
  if [[ "${result}" == {* ]]; then
    send_http_response 400 "Bad Request" "application/json" '{"error": "Account for this email address already exists"}'
    exit 1
  fi

  # then delete any existing in-process signups
  local result=$(delete_many_by_filter "signups" '{email: "'${email}'"}')
  handle_db_errors "${result}"

  # add to signups in process
  local password=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.password')
  local sha256=$(echo -n "$password" | ${SHASUM256_CMD} | awk -F' ' '{print $1}')
  local user=$(echo "${HTTP_REQUEST_BODY}" | jq -c '.password = '\"${sha256}\")
  local result=$(add_one "signups" "${user}")
  handle_db_errors "${result}"

  # send email with verify link
  local id=$(echo "${result}" | jq -r '.insertedId')
  send_email "${email}" "Verify your email address for funwithbash.com" "Please click this link to verify your email address: ${EMAIL_LINK_BASE_URL}/#verifyEmail/${id}"
  send_http_response 201 "Created" "application/json" "${result}"
}

function handle_forgot_password() {
  local email=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.email')

  # email is required, not empty, and is xss protected
  if [[ "${email}" == "null" ]] || [[ -z "${email}" ]] || [[ "${email}" =~ [\<\>]+ ]]; then
    send_http_response 400 "Bad Request" "text/html" '{"error": "\"email\": cannot be empty and cannot contain < or > characters"}'
    exit 1
  fi

  # check if user account exists
  local result=$(get_one_by_filter "users" '{email: "'${email}'"}')
  if [[ "${result}" != {* ]]; then
    send_http_response 400 "Bad Request" "application/json" '{"error": "Account for this email address does not exist"}'
    exit 1
  fi

  # delete any existing reset for this email
  local result=$(delete_many_by_filter "resets" '{email: "'${email}'"}')
  handle_db_errors "${result}"

  # generate a password reset link
  local result=$(add_one "resets" '{email: "'${email}'"}')
  handle_db_errors "${result}"

  # send email with link
  local id=$(echo "${result}" | jq -r '.insertedId')
  send_email "${email}" "Reset your password for funwithbash.com" "Please click this link to reset your password: ${EMAIL_LINK_BASE_URL}/#resetPassword/${id}"
  send_http_response 201 "Created" "application/json" "${result}"
}


function handle_verify_email() {
  local id=${BASH_REMATCH[1]}

  # verify signup exists
  local result=$(get_one "signups" "${id}")
  handle_db_errors "${result}"

  # create account
  local user=$(echo "${result}" | jq -r 'del(._id)')
  local result=$(add_one "users" "${user}")

  # delete signup
  local result=$(delete_one "signups" "${id}")
  handle_db_errors "${result}"

  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_reset_password() {
  local id=${BASH_REMATCH[1]}

  # verify reset exists
  local result=$(get_one "resets" "${id}")
  handle_db_errors "${result}"

  # find user
  local email=$(echo "${result}" | jq -r '.email')
  local result=$(get_one_by_filter "users" '{email: "'${email}'"}')
  local user_id=$(echo "${result}" | jq -r '._id')

  # reset password

  local temp_password=$(head -c 2048 /dev/urandom | ${MD5_CMD} | head -c 22 ; echo -n)
  local sha256=$(echo -n "$temp_password" | ${SHASUM256_CMD} | awk -F' ' '{print $1}')
  local user=$(echo "${result}" | jq -r 'del(._id)' | jq -c '.password = "'${sha256}'"')
  local result=$(update_one "users" "${user_id}" "${user}")

  # delete reset
  local result=$(delete_one "resets" "${id}")
  handle_db_errors "${result}"

  # send email with temp password
  send_email "${email}" "Password has been reset for funwithbash.com" "Please login with this temporary password and then proceed to change your password: ${temp_password}"

  send_http_response 200 "OK" "application/json" "${result}"
}

function handle_change_password() {
  # validate the payload
  validate_user "${HTTP_REQUEST_BODY}"

  # verify that email matches authenticated user
  local email=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.email')
  if [[ "${email}" != "${USER_EMAIL}" ]]; then
    send_http_response 400 "Bad Request" "application/json" '{error: "Invalid email address"}'
  fi

  # get the user from database
  local result=$(get_one_by_filter "users" '{email: "'${email}'"}')
  handle_db_errors "${result}"

  # now update it
  local id=$(echo "${result}" | jq -r '._id')
  local password=$(echo "${HTTP_REQUEST_BODY}" | jq -r '.password')
  local sha256=$(echo -n "$password" | ${SHASUM256_CMD} | awk -F' ' '{print $1}')
  local user=$(echo "${HTTP_REQUEST_BODY}" | jq -c '.password = '\"${sha256}\")
  local result=$(update_one "users" "${id}" "${user}")
  handle_db_errors "${result}"
  send_http_response 200 "OK" "application/json" "${result}"
}

# add routes
add_route_anon 'POST' '^/api/login$' 'handle_login_user'
add_route_anon 'POST' '^/api/signup$' 'handle_signup_user'
add_route_anon 'GET' '^/api/verifyEmail/(.+)$' 'handle_verify_email'
add_route_anon 'POST' '^/api/forgotPassword$' 'handle_forgot_password'
add_route_anon 'GET' '^/api/resetPassword/(.+)$' 'handle_reset_password'
add_route 'POST' '^/api/logout$' 'handle_logout_user'
add_route 'GET' '^/api/authValid$' 'handle_auth_valid'
add_route 'POST' '^/api/changePassword$' 'handle_change_password'
