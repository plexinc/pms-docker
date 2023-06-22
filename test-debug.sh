#!/bin/bash

# This is just a helper script to quickly test local Dockerfile builds

# build variations
#--build-arg AUTOUPDATE=false 
#--build-arg URL=https://plex.tv//updater/packages/166139/file 
#--build-arg TAG=public

ID=$(docker build --build-arg AUTOUPDATE=TRUE --build-arg TAG=beta . 2>&1 | tee /dev/fd/2 build.log | tail -1 | awk '{ print $3}')

# with persistent volume
docker run --rm -it -v testing-vol:/config:rw "$ID" 
# without  persistent volume
# docker run --rm -it -v "$ID" bash

