#!/bin/sh
set -e
currentDir="$(dirname "$0")"

# Host to use. Needs to include the protocol.
host=$1
# Credentials to use for the test. USER:PASS format.
credentials=$2
# concurrency level of the throughput test: How many requests should
# open in parallel.
concurrency=$3
# How many threads to utilize, directly correlates to the number
# of CPU cores
threads=${4:-4}
# How long to run the test
duration=${5:-30s}

action="noopThroughput"
"$currentDir/create.sh" "$host" "$credentials" "$action"

# run throughput tests
encodedAuth=$(echo "$credentials" | base64 -w0)
docker run --pid=host --userns=host --rm -v $(pwd):/data williamyeh/wrk \
  --threads "$threads" \
  --connections "$concurrency" \
  --duration "$duration" \
  --header "Authorization: basic $encodedAuth" \
  "$host/api/v1/namespaces/_/actions/$action?blocking=true" \
  --latency \
  --script post.lua