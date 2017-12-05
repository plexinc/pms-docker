#!/bin/bash

function getVersionInfo {
  local version="$1"
  local token="$2"
  declare -n remoteVersion=$3
  declare -n remoteFile=$4
  
  local channel
  local tokenNeeded=1
  if [ ! -z "${PLEX_UPDATE_CHANNEL}" ] && [ "${PLEX_UPDATE_CHANNEL}" > 0 ]; then
    channel="${PLEX_UPDATE_CHANNEL}"
  elif [ "${version,,}" = "beta" ]; then
    channel=8
  elif [ "${version,,}" = "public" ]; then
    channel=16
    tokenNeeded=0
  else
    channel=8
  fi
  
  local url="https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=${channel}&distro=ubuntu"
  if [ ${tokenNeeded} -gt 0 ]; then
    url="${url}&X-Plex-Token=${token}"
  fi
  
  local versionInfo="$(curl -s "${url}")"
  
  # Get update info from the XML.  Note: This could countain multiple updates when user specifies an exact version with the lowest first, so we'll use first always.
  remoteVersion=$(echo "${versionInfo}" | sed -n 's/.*Release.*version="\([^"]*\)".*/\1/p')
  remoteFile=$(echo "${versionInfo}" | sed -n 's/.*file="\([^"]*\)".*/\1/p')
}


function installFromUrl {
  installFromRawUrl "https://plex.tv/${1}"
}

function installFromRawUrl {
  local remoteFile="$1"
  curl -J -L -o /tmp/plexmediaserver.deb "${remoteFile}"
  local last=$?

  # test if deb file size is ok, or if download failed
  if [[ "$last" -gt "0" ]] || [[ $(stat -c %s /tmp/plexmediaserver.deb) -lt 10000 ]]; then
    echo "Failed to fetch update"
    exit 1
  fi

  dpkg -i --force-confold /tmp/plexmediaserver.deb
  rm -f /tmp/plexmediaserver.deb
}
