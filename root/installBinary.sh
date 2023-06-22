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
if [ "${AUTOUPDATE,,}" = 'true' ]; then
    echo "AUTOUPDATE requested, setting up cron service and scheduling plex-update"
    mkdir -p /etc/services.d/cron ; ln -s /etc/plex/service.cron.run /etc/services.d/cron/run
    # Specify bash as shell, add S6 commands to PATH
    echo "SHELL=/bin/bash" > /etc/crontab
    echo "$(env | grep PATH):/command" >> /etc/crontab
    # Specify cron job: be nice to Plex servers - space out updates at 4:00am over 30m window
    echo "0 4 * * * root perl -le 'sleep rand 30' ; /etc/plex/plex-update > /proc/1/fd/1 2>&1" >> /etc/crontab
    echo "Removing plex-update from cont-init.d"
    rm /etc/cont-init.d/020-plex-update
    echo "Adding plex-install to cont-init.d"
    ln -s /etc/plex/plex-install /etc/cont-init.d/099-plex-install
    exit 0
fi
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
  rm -rf /config/install
fi
