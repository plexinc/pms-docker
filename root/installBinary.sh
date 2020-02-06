#!/bin/bash

. /plex-common.sh

## TODO : Make a file with these 3 variables ##
echo "${TAG}" > /version.txt
echo "${PLEX_BUILD}" > /plex-build.txt
echo "${PLEX_DISTRO}" > /plex-distro.txt
if [ ! -z "${URL}" ]; then
  echo "Attempting to install from URL: ${URL}"
  installFromRawUrl "${URL}"
elif [ "${TAG}" != "beta" ] && [ "${TAG}" != "public" ]; then
  getVersionInfo "${TAG}" "" remoteVersion remoteFile

  if [ -z "${remoteVersion}" ] || [ -z "${remoteFile}" ]; then
    echo "Could not get install version"
    exit 1
  fi
  
  echo "Attempting to install: ${remoteVersion}"
  installFromUrl "${remoteFile}"
fi
