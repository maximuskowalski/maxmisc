#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/wanchplus.sh
# A script to watch rclone mount anchors and stop muh dockers.
# and then restart a services like mergerfs.

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

IFS=$'\n\t'

#________ VARS ( CONFIG FILE ( REPO WIDE))
# shellcheck source-path=SCRIPTDIR
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

# anchor=audiobooks,td_tv2.bin                     # anchors, use commas (a directory is also a file)
# dir="/mnt/unionfs"                               # location of anchor files
# sapps="plex emby emby2 plexhex jellyfin calibre" # docker service apps, separate with spaces.
# sysapps="rclone_vfs mergerfs munter"             # system services, separate with spaces.
# wanchcommands="sudo mount -a"                    # Commands to be executed when anchor is not found
# wanchlog="/home/max/logs/wanch.log"              # logfile

#________ FUNCTIONS

# check and deny root runners
root_runner() {
  if [ $EUID -eq 0 ]; then
    echo "This script cannot be run as root."
    exit 1
  fi
}

check_requirements() {
  for cmd in docker systemctl apprise; do
    if ! command -v $cmd &>/dev/null; then
      msg="Error: $cmd is not installed."
      send_notification "${msg}"
      echo "${msg}" >&2
      exit 1
    fi
  done
}

# check for logfile and dir existence
safety_check() {
  if [ ! -d "$logsdir" ]; then
    mkdir -p "$logsdir"
  fi
  if [ ! -f "$logsdir/wanch.log" ]; then
    touch "$logsdir/wanch.log"
  fi
}

checker() {
  for VAL in ${anchor//,/ }; do
    ([ -e "${dir}"/"${VAL}" ] || thrillkillkult)
  done
}

thrillkillkult() {
  if [[ -n "${sapps}" ]]; then
    docker stop "${sapps}"
  fi

  if [[ -n "${sysapps}" ]]; then
    sudo systemctl restart "${sysapps}"
  fi

  if [[ -n "${wanchcommands}" ]]; then
    ${wanchcommands}
  fi

  if [[ -n "${sapps}" ]]; then
    docker start "${sapps}"
  fi

  msg="Time: $(date). Mount dropped, ${sysapps} ${sapps} restarted. ${wanchcommands}"

  echo "${msg}" >>${wanchlog}
  send_notification "${msg}"
}

#________ notifications

send_notification() {
  local msg="$1"

  # Check if webhook_url is set and is not a default value
  if [ -z "$webhook_url" ] || [ "$webhook_url" = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" ]; then
    echo "ERROR: webhook URL is not set or is invalid." >>"${wanchlog}"
    return 1
  fi

  # Use apprise command to send notification with HTML formatting
  echo "Sending notification: $msg" >>"${wanchlog}"
  apprise "$webhook_url" --title "wanchPlus $thisserver" --input-format=html --body "$msg"

  # Check if apprise command was successful
  if [ $? -ne 0 ]; then
    echo "Time: $(date). ERROR: Failed to send notification with apprise." >>"${wanchlog}"
    return 1
  fi
}

# Main function to run the checker
main() {
  root_runner
  check_requirements
  safety_check
  checker
}

#________ EXECUTION
main
