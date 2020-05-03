#!/usr/bin/with-contenv bash

if !(cat /proc/1/cgroup | grep -q '/docker/'); then
  echo "Not a docker container"
  exit 0
fi

# If we are debugging, enable trace
if [ "${DEBUG,,}" = "true" ]; then
  set -x
fi

. /plex-common.sh

pmsApplicationSupportDir="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-${HOME}/Library/Application Support}"
prefFile="${pmsApplicationSupportDir}/Plex Media Server/Preferences.xml"

function getPref {
  local key="$1"

  xmlstarlet sel -T -t -m "/Preferences" -v "@${key}" -n "${prefFile}"
}

token="$(getPref "PlexOnlineToken")"

# Determine current version
if (dpkg --get-selections plexmediaserver 2> /dev/null | grep -wq "install"); then
  installedVersion=$(dpkg-query -W -f='${Version}' plexmediaserver 2> /dev/null)
else
  installedVersion="none"
fi

# Read set version
versionToInstall="$(cat /version.txt)"
if [ -z "${versionToInstall}" ]; then
  echo "No version specified in install.  Broken image"
  exit 1
fi

# Short-circuit test of version before remote check to see if it's already installed.
if [ "${versionToInstall}" = "${installedVersion}" ]; then
  exit 0
fi

# Get updated version number
getVersionInfo "${versionToInstall}" "${token}" remoteVersion remoteFile

if [ -z "${remoteVersion}" ] || [ -z "${remoteFile}" ]; then
  echo "Could not get update version"
  exit 0
fi

# Check if there's no update required and silently exit
if [ "${remoteVersion}" = "${installedVersion}" ]; then
  exit 0
fi

echo "Local version: ${installedVersion}"
echo "Remove version: ${remoteVersion}"
echo "Triggering reboot to force update"
kill 1
