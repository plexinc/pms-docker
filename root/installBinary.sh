#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

. /plex-common.sh

addVarToConf "version" "${TAG}"
addVarToConf "plex_build" "${PLEX_BUILD}"
addVarToConf "plex_distro" "${PLEX_DISTRO}"

# Setup common services
echo "Creating services"
mkdir -p /etc/services.d/plex ; ln -s /etc/plex/service.plex.run /etc/services.d/plex/run
mkdir -p /etc/cont-init.d
ln -s /etc/plex/plex-first-run /etc/cont-init.d/000-plex-first-run
ln -s /etc/plex/plex-hw-transcode-and-connected-tuner /etc/cont-init.d/010-plex-hw-transcode-and-connected-tuner
ln -s /etc/plex/plex-update /etc/cont-init.d/020-plex-update

if [ -n "${URL}" ]; then
  echo "Attempting to install from URL: ${URL}"
  installFromRawUrl "${URL}"
elif [ "${TAG}" != "beta" ] && [ "${TAG}" != "public" ]; then
  remoteVersion=
  remoteFile=
  getVersionInfo "${TAG}" "" remoteVersion remoteFile

  if [ -z "${remoteVersion}" ] || [ -z "${remoteFile}" ]; then
    echo "Could not get install version"
    exit 1
  fi
  
  echo "Attempting to install: ${remoteVersion}"
  installFromUrl "${remoteFile}"
fi
