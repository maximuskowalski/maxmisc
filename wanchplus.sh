#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/wanchors.sh
# A script to watch rclone mount anchors and stop muh dockers.
# and then restart a services like mergerfs.

# shellcheck disable=SC2154

# set -x

#________ VARS ( CONFIG FILE ( REPO WIDE))
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

anchor=audiobooks,td_tv2.bin                     # anchors, use commas (a directory is also a file)
dir="/mnt/unionfs"                               # location of anchor files
sapps="plex emby emby2 plexhex jellyfin calibre" # docker service apps, separate with spaces.
sysapps="rclone_vfs mergerfs munter"             # system services, separate with spaces.
wanchlog="/home/max/logs/wanch.log"              # logfile

checker() {
  for VAL in ${anchor//,/ }; do
    ([ -e "${dir}"/"${VAL}" ] || thrillkillkult)
  done
}

thrillkillkult() {
  docker stop "${sapps}"
  sudo systemctl restart "${sysapps}"
  docker start "${sapps}"
  echo "Time: $(date). mount dropped, ${sysapps} restarted." >>${wanchlog}
}

checker
