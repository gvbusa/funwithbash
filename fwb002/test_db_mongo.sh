#!/usr/bin/env bash

# test db_mongo.sh
# we will add a document to a tasks collection, get all documents in the collection, and
# finally delete the document by its ObjectId _id"

# imports
source "./db_mongo.sh"

# add a document
output=$(add "tasks" '{"name": "My first task", "notes": "Write this test for db_mongo.sh!"}')
echo "${output}"

# get all documents
output=$(get_all "tasks")
echo "${output}"

# get the id
id=$(echo "${output}" | jq -r '.[]."_id"')
echo "_id is ${id}"
delete_one "tasks" "${id}"
