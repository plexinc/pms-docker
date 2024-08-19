#!/bin/bash

. /plex-common.sh

PLEX_BUILD=''
if [ "${TARGETPLATFORM}" = 'linux/arm/v7' ]; then
  PLEX_BUILD='linux-armv7hf_neon'
elif [ "${TARGETARCH}" = 'amd64' ]; then
  PLEX_BUILD='linux-x86_64';
elif [ "${TARGETARCH}" = 'arm64' ]; then
  PLEX_BUILD='linux-aarch64' ;
fi

addVarToConf "version" "${TAG}"
addVarToConf "plex_build" "${PLEX_BUILD}"
addVarToConf "plex_distro" "${PLEX_DISTRO}"

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
