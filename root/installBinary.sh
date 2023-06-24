#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

DEBUG=${DEBUG:-}

# If we are debugging, enable trace
if [ "${DEBUG,,}" = "true" ]; then
  set -x
fi

. /plex-common.sh

addVarToConf "tag" "${TAG}"
addVarToConf "plex_build" "${PLEX_BUILD}"
addVarToConf "plex_distro" "${PLEX_DISTRO}"

# Setup common services
echo "Creating services"
mkdir -p /etc/services.d/plex ; ln -s /etc/plex/service.plex.run /etc/services.d/plex/run
mkdir -p /etc/cont-init.d
ln -s /etc/plex/plex-first-run /etc/cont-init.d/000-plex-first-run
ln -s /etc/plex/plex-hw-transcode-and-connected-tuner /etc/cont-init.d/010-plex-hw-transcode-and-connected-tuner
if [ -n "${URL}" ]; then
  echo "Attempting to install from URL: ${URL}"
  installFromRawUrl "${URL}"
elif [ "${TAG,,}" = "autoupdate" ] || [ "${TAG,,}" = "beta" ] || [ "${TAG,,}" = "public" ]; then
  echo "AUTOUPDATE requested, skipping download and install, setting up cron service and scheduling plex-update"
  mkdir -p /etc/services.d/cron ; ln -s /etc/plex/service.cron.run /etc/services.d/cron/run
  # Specify bash as shell, add S6 commands to PATH
  echo "SHELL=/bin/bash" > /etc/crontab
  echo "$(env | grep PATH):/command" >> /etc/crontab
  # Specify cron job: be nice to Plex servers - space out updates at 4:00am over 30m window
  echo "0 4 * * * root perl -le 'sleep rand 1800' ; /etc/plex/plex-update > /proc/1/fd/1 2>&1" >> /etc/crontab
  echo "Adding plex-startup to cont-init.d"
  ln -s /etc/plex/plex-startup /etc/cont-init.d/099-plex-startup
else
  # This pre-installs the specified version in TAG into this docker image.
  remoteVersion=
  remoteFile=
  getVersionInfo "${TAG}" "" remoteVersion remoteFile

  if [ -z "${remoteVersion}" ] || [ -z "${remoteFile}" ]; then
    echo "Could not get install version"
    exit 1
  fi
  
  echo "Attempting to install: ${remoteVersion}"
  installFromUrl "${remoteFile}"
  # delete unnecessary installer
  rm -rf /config/install
fi
