#!/bin/bash

CONT_CONF_FILE="/version.txt"

# True if plex can modify the prefs dir, i.e. it or any existing parent is plex-writable.
# Requires setPrefFile to have been called
function plexCanWritePrefDir {
  local dir
  dir="$(dirname "${prefFile}")"
  while [[ "${dir}" != "/" ]]; do
    if [[ -e "${dir}" ]] && s6-setuidgid plex test -w "${dir}"; then
      return 0
    fi
    dir="$(dirname "${dir}")"
  done
  return 1
}

# shellcheck disable=SC2154 # CHANGE_CONFIG_DIR_OWNERSHIP comes from the container env
# Root must not act on files plex controls, so touch Preferences.xml as the plex user.
# Only a config dir plex can't write (with CHANGE_CONFIG_DIR_OWNERSHIP off) stays root.
function asPlex {
  if [[ "${CHANGE_CONFIG_DIR_OWNERSHIP,,}" = "true" ]] || plexCanWritePrefDir; then
    s6-setuidgid plex "$@"
  else
    "$@"
  fi
}

# Resolve the PMS app support dir, shared by PMS (services.d/plex/run) and the init scripts
function setAppSupportDir {
  local home
  home=~plex
  [[ -f /etc/default/plexmediaserver ]] && . /etc/default/plexmediaserver
  pmsApplicationSupportDir="${PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR:-${home}/Library/Application Support}"
}

function setPrefFile {
  setAppSupportDir
  prefFile="${pmsApplicationSupportDir}/Plex Media Server/Preferences.xml"
}

# Requires setPrefFile to have been called
function getPref {
  local key="$1"

  asPlex xmlstarlet sel -T -t -m "/Preferences" -v "@${key}" -n "${prefFile}"
}

function addVarToConf {
  local variable="$1"
  local value="$2"
  if [[ -n "${variable}" ]]; then
    echo "${variable}=${value}" >> "${CONT_CONF_FILE}"
  fi
}

function readVarFromConf {
  local variable="$1"
  local -n readVarFromConf_value=$2
  if [[ -n "${variable}" ]]; then
    readVarFromConf_value="$(grep -w -- "${variable}" "${CONT_CONF_FILE}" | cut -d'=' -f2 | tail -n 1)"
  else
    # shellcheck disable=SC2034 # nameref: assigns the caller's variable
    readVarFromConf_value=NULL
  fi
}

function getVersionInfo {
  local version="$1"
  local token="$2"
  local -n getVersionInfo_remoteVersion=$3
  local -n getVersionInfo_remoteFile=$4

  local channel plexBuild plexDistro versionInfo
  local tokenNeeded=1
  # shellcheck disable=SC2292 # keep [ ]: [[ -gt ]] would arithmetic-eval env input
  if [[ -n "${PLEX_UPDATE_CHANNEL}" ]] && [ "${PLEX_UPDATE_CHANNEL}" -gt 0 ] 2>/dev/null; then
    channel="${PLEX_UPDATE_CHANNEL}"
  elif [[ "${version,,}" = "beta" ]]; then
    channel=8
  elif [[ "${version,,}" = "public" ]]; then
    channel=16
    tokenNeeded=0
  else
    channel=8
  fi

  # Read container architecture info from file created when building Docker image
  readVarFromConf "plex_build" plexBuild
  readVarFromConf "plex_distro" plexDistro

  local -a query=(
    --data-urlencode "build=${plexBuild}"
    --data-urlencode "channel=${channel}"
    --data-urlencode "distro=${plexDistro}"
  )
  if [[ "${tokenNeeded}" -gt 0 ]]; then
    query+=(--data-urlencode "X-Plex-Token=${token}")
  fi

  # -q (must be the first arg): ignore ~/.curlrc, HOME=/config is plex-writable
  versionInfo="$(curl -q -s -G "${query[@]}" "https://api.plex.tv/downloads/details/5")"

  # Get update info from the XML.  Note: This could countain multiple updates when user specifies an exact version with the lowest first, so we'll use first always.
  # shellcheck disable=SC2034 # namerefs: assign the caller's variables
  getVersionInfo_remoteVersion=$(echo "${versionInfo}" | sed -n 's/.*Release.*version="\([^"]*\)".*/\1/p')
  # shellcheck disable=SC2034
  getVersionInfo_remoteFile=$(echo "${versionInfo}" | sed -n 's/.*file="\([^"]*\)".*/\1/p')
}


function installFromUrl {
  installFromRawUrl "https://api.plex.tv/${1}"
}

function installFromRawUrl {
  local remoteFile="$1"
  local deb last
  deb="$(mktemp --suffix=.deb)" || exit 1
  # Expand now: ${deb} is local and may be out of scope when the trap fires
  # shellcheck disable=SC2064
  trap "rm -f '${deb}'" EXIT
  curl -q --fail -L -o "${deb}" "${remoteFile}"
  last=$?

  # test if deb file size is ok, or if download failed
  if [[ "${last}" -gt 0 ]] || [[ $(stat -c %s "${deb}") -lt 10000 ]]; then
    echo "Failed to fetch update"
    rm -f "${deb}"
    exit 1
  fi

  dpkg -i --force-confold --force-architecture "${deb}"
  rm -f "${deb}"
}
