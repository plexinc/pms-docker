#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This is just a helper script to quickly test local Dockerfile builds, please run setup-build-env.sh once

docker run --rm --name pms-386 --platform linux/386 -e DEBUG=true -it pms-386:latest bash