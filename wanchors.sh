#!/bin/bash
# A script to watch for rclone mount anchors and stop muh dockers.

# VARIABLES
ANCHOR=td_tv1.bin,td_movies.bin   # anchor files, use commas
DIR="/mnt/unionfs"                # location of anchor files
SAPPS="plex emby jellyfin"        # docker service apps, separate with spaces.
NOTIFICATION="/opt/somescript.sh" # place holder

checker() {
  for VAL in ${ANCHOR//,/ }; do
    ([ -e "${DIR}"/"${VAL}" ] || thrillkillkult)
  done
}

thrillkillkult() {
  docker stop ${SAPPS}
}

checker

#
