#!/usr/bin/env bash

#set -x

#
# This script implements CRUD operations on a given mongodb collection.
# It uses the mongosh command line utility to connect to a mongo cluster in the
# mongo atlas cloud (free tier).
#

#
# globals
#

# Database timeout in seconds, can be fractional
MONGO_TIMEOUT=3

#IN_PIPE=<get from environment variable>
#OUT_PIPE=<get from environment variable>
#PIPE_IN_USE=<get from environment variable>

#
# functions
#

# send script to mongosh running in background to have it executed
function exec_mongo {
  local script=$1

  # use lock to ensure that only one instance of bash script is doing this at one time
  exec 100>$PIPE_LOCK || exit 1
  flock 100 || exit 1

  # write command to IN_PIPE
  echo "${script}" >$IN_PIPE

  # discard prompt
  read -n 1000 -d ">" -t $MONGO_TIMEOUT discard <$OUT_PIPE

  # read response line
  read -r -t $MONGO_TIMEOUT line <$OUT_PIPE
  if [[ -z "${line}" ]]; then
    log_info "Error: Database timeout"
    return
  fi

  # return database response
  echo $line
}

# add given document to given collection
function add_one {
  local coll=$1
  local doc=$2
  local script="JSON.stringify(db.${coll}.insertOne(${doc}))"
  exec_mongo "${script}"
}

# get all documents from given collection
function get_all {
  local coll=$1
  local script="JSON.stringify(db.${coll}.find().toArray())"
  exec_mongo "${script}"
}

# get document with given object_id from given collection
function get_one {
  local coll=$1
  local id=$2
  local script="JSON.stringify(db.${coll}.findOne(ObjectId(\"${id}\")))"
  exec_mongo "${script}"
}

# update given document with given object_id in given collection
function update_one {
  local coll=$1
  local id=$2
  local doc=$3
  local script="JSON.stringify(db.${coll}.updateOne({\"_id\": ObjectId(\"${id}\")}, {\$set: ${doc}}))"
  exec_mongo "${script}"
}

# delete document with given object_id from given collection
function delete_one {
  local coll=$1
  local id=$2
  local script="JSON.stringify(db.${coll}.deleteOne({\"_id\": ObjectId(\"${id}\")}))"
  exec_mongo "${script}"
}


