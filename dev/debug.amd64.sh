#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This is just a helper script to quickly test local Dockerfile builds, please run setup-build-env.sh once

docker run --rm --name pms-amd64 -e DEBUG=true -it pms-amd64:latest bash