#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This is just a helper script to quickly test local Dockerfile builds, please run setup-build-env.sh once

# https://github.com/tianon/docker-brew-ubuntu-core/issues/183
docker buildx build --progress=plain --security-opt seccomp:unconfined -o type=docker,name=pms-arm64 --load --platform linux/arm64 --build-arg AUTOUPDATE=TRUE -f ../Dockerfile ..
