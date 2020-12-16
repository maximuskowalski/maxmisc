#!/bin/bash
# A script to watch for rclone mount anchors and stop muh dockers and then restart a service like mergerfs.

# VARIABLES
ANCHOR=audiobooks,td_tv2.bin                          # anchors, use commas (a directory is also a file)
DIR="/mnt/unionfs"                                    # location of anchor files
SAPPS="plex emby emby2 plexhex jellyfin calibre"      # docker service apps, separate with spaces.
SYSAPPS="mergerfs munter"                             # system services, separate with spaces.
WANCHLOG="/home/max/logs/wanch.log"                   # logfile

checker() {
  for VAL in ${ANCHOR//,/ }; do
    ([ -e "${DIR}"/"${VAL}" ] || thrillkillkult)
  done
}

thrillkillkult() {
  docker stop ${SAPPS}
  sudo systemctl restart ${SYSAPPS}
  docker start ${SAPPS}
  echo "Time: "$(date)". mount dropped, "${SYSAPPS}" restarted." >> ${WANCHLOG}
}

checker

#
