#!/usr/bin/env bash

#
# This script implements CRUD operations on a given mongodb collection.
# It uses the mongosh command line utility to connect to a mongo cluster in the
# mongo atlas cloud (free tier).
#

#
# globals
#
#MONGO_USER=<get from environment variable>
#MONGO_PASSWORD=<get from environment variable>
MONGO_URI="mongodb+srv://cluster0.cgru0nq.mongodb.net/fwb"

#
# functions
#

# connect to your mongodb database and execute given script
function exec_mongo {
  local script=$1
  output=$( mongosh "${MONGO_URI}" --quiet --norc--apiVersion 1 --username ${MONGO_USER} --password ${MONGO_PASSWORD} --eval "${script}")
  echo $output
}

# add given document to given collection
function add {
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

# delete document with given object_id from given collection
function delete_one {
  local coll=$1
  local id=$2
  local script="JSON.stringify(db.${coll}.deleteOne({\"_id\": ObjectId(\"${id}\")}))"
  exec_mongo "${script}"
}


