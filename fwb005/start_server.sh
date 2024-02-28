#!/usr/bin/env bash

trap cleanup EXIT

#
# This script creates input and output named pipes and runs mongosh in the background
# with I/O redirected to the named pipes. It then starts ncat.
#

#
# globals
#
#MONGO_USER=<get from environment variable>
#MONGO_PASSWORD=<get from environment variable>
MONGO_URI="mongodb+srv://cluster0.cgru0nq.mongodb.net/fwb"

export IN_PIPE=/tmp/in_pipe
export OUT_PIPE=/tmp/out_pipe

#
# functions
#
function cleanup() {
  rm -f $IN_PIPE
  rm -f $OUT_PIPE
}

#
# main script
#

cleanup

# create named pipes
if ! [[ -p $IN_PIPE ]]; then
  mkfifo $IN_PIPE
fi
if ! [[ -p $OUT_PIPE ]]; then
  mkfifo $OUT_PIPE
fi

# run mongosh in background with named pipes for I/O
mongosh "${MONGO_URI}" --quiet --norc--apiVersion 1 --username ${MONGO_USER} --password ${MONGO_PASSWORD} <$IN_PIPE >$OUT_PIPE &

# run ncat
ncat --listen --keep-open --source-port 7777 --sh-exec "./task_app.sh"


