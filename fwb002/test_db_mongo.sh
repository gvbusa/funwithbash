#!/usr/bin/env bash

# test db_mongo.sh
# we will add a document to a tasks collection, get all documents in the collection, and
# finally delete the document by its ObjectId _id"

# imports
source "./db_mongo.sh"

# add a document
echo "testing add_one:"
add_one "tasks" '{"name": "My first task", "notes": "Write this test for db_mongo.sh!"}'

# get all documents
echo "testing get_all:"
output=$(get_all "tasks")
echo "${output}"

# get the id
id=$(echo "${output}" | jq -r '.[]."_id"')
echo "_id is ${id}"

# update one
echo "testing update_one:"
updated_doc='{"name": "My updated task", "notes": "Updated - Write this test for db_mongo.sh!"}'
update_one "tasks" "${id}" "${updated_doc}"

# get one
echo "testing get_one:"
get_one "tasks" "${id}"

# delete one
echo "testing delete_one:"
delete_one "tasks" "${id}"
