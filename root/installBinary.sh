#!/bin/bash

. /plex-common.sh

echo "${TAG}" > /version.txt
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
