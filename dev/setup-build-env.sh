#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This is a one time setup script to setup the build env needed by the build and debug scripts. 
# Assumes this is running on Linux (any distro) using (intel/amd). 

# Create a multi-arch buildx builder named PlexBuilder (if it doesn't exist)
if ! docker buildx inspect PlexBuilder 1> /dev/null 2>& 1; then
    echo Creating PlexBuilder
    # --use will make it automatically use this builder
    docker buildx create --name PlexBuilder --platform linux/arm64,linux/arm/v7,linux/386 --use
    # this is needed to register the arch-specific images with QEMU to be able to test
    # these without native hardware
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
fi
