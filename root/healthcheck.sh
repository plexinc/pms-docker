#!/bin/sh -e

TARGET=localhost
CURL_OPTS="--connect-timeout 15 --max-time 100 --silent --show-error --fail"

# shellcheck disable=SC2086 # CURL_OPTS is a fixed, intentionally split option list
curl ${CURL_OPTS} "http://${TARGET}:32400/identity" >/dev/null

