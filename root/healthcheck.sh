#!/bin/sh -e

TARGET=localhost
CURL_OPTS="--connect-timeout 15 --max-time 100 --silent --show-error --fail"

# -q (must be the first arg): ignore ~/.curlrc, HOME=/config is plex-writable
# shellcheck disable=SC2086 # CURL_OPTS is a fixed, intentionally split option list
curl -q ${CURL_OPTS} "http://${TARGET}:32400/identity" >/dev/null

