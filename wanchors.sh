#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/wanchors.sh
# A script to watch rclone mount anchors and stop muh dockers.

# shellcheck disable=SC2154

# set -x

#________ VARS ( CONFIG FILE ( REPO WIDE))
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

# anchor=td_tv1.bin,td_movies.bin # anchor files, use commas
# dir="/mnt/unionfs"              # location of anchor files
# sapps="plex emby jellyfin"      # docker service apps, separate with spaces.

checker() {
  for VAL in ${anchor//,/ }; do
    ([ -e "${dir}"/"${VAL}" ] || thrillkillkult)
  done
}

thrillkillkult() {
  docker stop "${sapps}"
}

checker
