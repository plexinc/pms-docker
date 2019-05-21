#!/usr/bin/with-contenv bash

# Check to make sure the device exists.  If it doesn't exit as there is nothing for us to do
if [ ! -e /dev/dri ]; then
	exit 0
fi

# Get the group IDs for the dri devices and the video group
DEVICE_GID=$(stat -c '%g' /dev/dri/* | grep -v '^0$' | head -n 1)
VIDEO_GID=$(getent group video | awk -F: '{print $3}')

# If the video group's ID matches the group ID of the device, exit as permissions are already setup.
if [ "${DEVICE_GID}" == "${VIDEO_GID}" ]; then
	exit 0
fi

# Get the current group name for the device's group ID
CURRENT_GROUP=$(getent group ${DEVICE_GID} | awk -F: '{print $1}')

if [ -z "${CURRENT_GROUP}" ]; then
	# If there is no group name for the device's group ID, change the video group to that ID.
	groupmod -g ${DEVICE_GID} video
else
	# There is a group name, so add it to the plex user's list of groups
	usermod -a -G ${CURRENT_GROUP} plex
fi