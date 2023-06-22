#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This is just a helper script to quickly test local Dockerfile builds, please run setup-build-env.sh once

docker buildx build -o type=docker,name=pms-386 --load --platform linux/386 -f ../Dockerfile.i386 ..
