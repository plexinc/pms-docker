#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

PLEX_UPDATE_CHANNEL=${PLEX_UPDATE_CHANNEL:-}

CONT_CONF_FILE="/version.txt"

function addVarToConf {
  local variable="$1"
  local value="$2"
  if [ -n "${variable}" ]; then
    echo "$variable"="$value" >> $CONT_CONF_FILE
  fi
}

function readVarFromConf {
  local variable="$1"
  local -n readVarFromConf_value=$2
  if [ -n "${variable}" ]; then
    readVarFromConf_value="$(grep -w "$variable" $CONT_CONF_FILE | cut -d'=' -f2 | tail -n 1)"
  else
    # shellcheck disable=SC2034
    readVarFromConf_value=NULL
  fi
}

function getVersionInfo {
  local version="$1"
  local token="$2"
  local -n getVersionInfo_remoteVersion=$3
  local -n getVersionInfo_remoteFile=$4
  local -n getVersionInfo_remoteFileHashSha256=$5

  local channel=
  local tokenNeeded=1
  if [ -n "${PLEX_UPDATE_CHANNEL}" ] && [ "${PLEX_UPDATE_CHANNEL}" -gt 0 ]; then
    channel="${PLEX_UPDATE_CHANNEL}"
  elif [ "${version,,}" = "beta" ]; then
    channel=8
  elif [ "${version,,}" = "public" ]; then
    channel=16
    tokenNeeded=0
  else
    channel=8
  fi

  # Read container architecture info from file created when building Docker image
  local plexBuild=
  local plexDistro=
  readVarFromConf "plex_build" plexBuild
  readVarFromConf "plex_distro" plexDistro

  local url="https://plex.tv/downloads/details/5?build=${plexBuild}&channel=${channel}&distro=${plexDistro}"
  if [ ${tokenNeeded} -gt 0 ]; then
    url="${url}&X-Plex-Token=${token}"
  fi

  local versionInfo=
  versionInfo="$(curl -s "${url}")"

  # Get update info from the XML.  Note: This could countain multiple updates when user specifies an exact version with the lowest first, so we'll use first always.
  # shellcheck disable=SC2034
  getVersionInfo_remoteVersion=$(echo "${versionInfo}" | sed -n 's/.*Release.*version="\([^"]*\)".*/\1/p')
  # shellcheck disable=SC2034
  getVersionInfo_remoteFile=$(echo "${versionInfo}" | sed -n 's/.*file="\([^"]*\)".*/\1/p')
  # shellcheck disable=SC2034
  getVersionInfo_remoteFileHashSha256=$(echo "${versionInfo}" | sed -n 's/.*fileHashSha256="\([^"]*\)".*/\1/p')
}


function installFromUrl {
  installFromRawUrl "https://plex.tv/${1}" "${2:-}"
}

function installFromRawUrl {
  local remoteFile="$1"
  local expectedSha256="${2:-}"

  rm -rf /tmp/plexmediaserver.deb
  if curl --create-dirs -J -L -o /tmp/plexmediaserver.deb "${remoteFile}" ; then
    if [ -n "$expectedSha256" ]; then
      sha256=$(sha256sum  /tmp/plexmediaserver.deb | awk '{ print $1 }')
      # compare sha256, if provided
      if [ ! "$expectedSha256" = "$sha256" ]; then
        cleanup "Download failed: sha256sum does not match: expected=$expectedSha256 actual=$sha256"
      fi
    else
      # no sha256, check if size appears ok
      if [[ $(stat -c %s /tmp/plexmediaserver.deb) -lt 10000 ]]; then
        # shellcheck disable=SC2119
        cleanup "Download failed: size appears wrong"
      fi
    fi
    # looks good, move tmp into position

    install "$remoteFile"
  else
    # shellcheck disable=SC2119
    cleanup
  fi
}

function cleanup {
  local msg="${1:-"Download failed"}"
  rm -rf /tmp/plexmediaserver.deb
  echo "$msg"
  exit 1
}

function install {
  dpkg -i --force-confold /tmp/plexmediaserver.deb
  rm -rf /tmp/plexmediaserver.deb
  # clean up _force_ flag, if exists
  rm -rf /config/_force_
}
