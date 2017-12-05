#!/bin/sh -e

TARGET=localhost
CURL_OPTS="--max-time 15 --silent --show-error --fail"

curl ${CURL_OPTS} "http://${TARGET}:32400/identity" >/dev/null

