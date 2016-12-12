#!/bin/bash

echo "${TAG}" > /version.txt
if [ "${TAG}" != "plexpass" ] && [ "${TAG}" != "public" ]; then
  versionInfo="$(curl -s "https://plex.tv/downloads/details/1?build=linux-ubuntu-x86_64&channel=8&distro=ubuntu&X-Plex-Token=${token}&version=${TAG}")"
  remoteVersion=$(echo "${versionInfo}" | sed -n 's/.*Release.*version="\([^"]*\)".*/\1/p')
  remoteFile=$(echo "${versionInfo}" | sed -n 's/.*file="\([^"]*\)".*/\1/p')

  if [ -z "${remoteVersion}" ] || [ -z "${remoteFile}" ]; then
    echo "Could not get update version"
    exit 0
  fi
  
  echo "Atempting to upgrade to: ${remoteVersion}"
  rm -f /tmp/plexmediaserver*.deb
  wget -nv --show-progress --progress=bar:force:noscroll -O /tmp/plexmediaserver.deb \
    "https://plex.tv/${remoteFile}"
  last=$?

  # test if deb file size is ok, or if download failed
  if [[ "$last" -gt "0" ]] || [[ $(stat -c %s /tmp/plexmediaserver.deb) -lt 10000 ]]; then
    echo "Failed to fetch update"
    exit 1
  fi

  dpkg -i --force-confold /tmp/plexmediaserver.deb
  rm -f /tmp/plexmediaserver.deb
fi
