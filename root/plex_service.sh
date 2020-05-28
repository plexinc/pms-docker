#!/bin/bash

if [ "$#" -eq 1 ]; then
  s6-svc "$1" /var/run/s6/services/plex
else
  echo "No argument supplied; must be -u, -d, or -r."
fi
