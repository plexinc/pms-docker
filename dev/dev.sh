#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# This is just a helper script to quickly test local Dockerfile builds, please run setup() once
# Assumes this is running on Linux (any distro) using (intel/amd).

# This bakes the specific binary into the image, you can override these vars on command line
# DOCKERHUB_IMAGE=myorg/mycontainer ./dev/sh bake
VERSION_TO_BUILD=${VERSION_TO_BUILD:-"1.32.4.7195-7c8f9d3b6"}
DOCKERHUB_IMAGE=${DOCKERHUB_IMAGE:-"plexinc/pms-docker"}

setup() {
    # Create a multi-arch buildx builder named PlexBuilder (if it doesn't exist)
    if ! docker buildx inspect PlexBuilder 1> /dev/null 2>& 1; then
        echo Creating PlexBuilder
        # --use will make it automatically use this builder
        docker buildx create --name PlexBuilder --platform linux/arm64,linux/arm/v7,linux/386 --use
        # this is needed to register the arch-specific images with QEMU to be able to test
        # these without native hardware
        docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    fi
}
build() {
    platform=$1
    name=$2
    docker buildx build \
        --progress=plain \
        -o type=docker \
        --load \
        --platform "$platform" \
        --build-arg \
        "TAG=$VERSION_TO_BUILD" \
        -t "$name:$VERSION_TO_BUILD" \
        -t "$name:latest" \
        -f ../Dockerfile ..
    docker buildx build \
        --progress=plain \
        -o type=docker \
        --load \
        --platform "$platform" \
        --build-arg \
        "TAG=autoupdate" \
        -t "$name:autoupdate" \
        -f ../Dockerfile ..
}

debug() {
    platform=$1
    name=$2
    autoupdate=$3
    if [ "$autoupdate" = "autoupdate" ]; then
        name=$name:autoupdate
    else
        name=$name:latest
    fi
    if [[ $platform == linux/arm* ]]; then
        # shellcheck disable=SC2064
        trap "trap - SIGTERM && docker stop debug-plex" SIGINT SIGTERM EXIT
        docker run --rm --name debug-plex --platform "$platform" -e DEBUG=true "$name" &
        sleep 5
        docker exec -it debug-plex bash
    else
        docker run --rm --name debug-plex --platform "$platform" -e DEBUG=true -it "$name" bash
    fi
}

cmd=${1:-}
kind=${2:-}
[ "$cmd" = 'setup' ] && setup
[ "$cmd" = 'build' ] && [ "$kind" = '386' ] &&  build linux/386 pms-386
[ "$cmd" = 'build' ] && [ "$kind" = 'amd64' ] && build linux/amd64 pms-amd64
[ "$cmd" = 'build' ] && [ "$kind" = 'arm32v7' ] && build linux/arm/v7 pms-arm32v7
[ "$cmd" = 'build' ] && [ "$kind" = 'arm64v8' ] && build linux/arm64 pms-arm64v8
[ "$cmd" = 'buildall' ] && \
    build linux/386 pms-386 && \
    build linux/amd64 pms-amd64 && \
    build linux/arm/v7 pms-arm32v7 && \
    build linux/arm64 pms-arm64v8

[ "$cmd" = 'bake' ] && TAG=$VERSION_TO_BUILD IMAGE=$DOCKERHUB_IMAGE docker buildx bake

autoupdate=${3:-}
[ "$cmd" = 'debug' ] && [ "$kind" = '386' ] && debug linux/386 pms-386 "$autoupdate"
[ "$cmd" = 'debug' ] && [ "$kind" = 'amd64' ] && debug linux/amd64 pms-amd64 "$autoupdate"
[ "$cmd" = 'debug' ] && [ "$kind" = 'arm32v7' ] && debug linux/arm/v7 pms-arm32v7 "$autoupdate"
[ "$cmd" = 'debug' ] && [ "$kind" = 'arm64v8' ] && debug linux/arm64 pms-arm64v8 "$autoupdate"
