#!/bin/bash

. /plex-envvars

logs="$PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/Plex Media Server/Logs"
multitail --mergeall "$logs"/*

