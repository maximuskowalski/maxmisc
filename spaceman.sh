#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/spaceman.sh

# Monitors a drive for low disk space and sends a notification if the free space falls below a certain threshold.

# Cron entry to run the script hourly:
# 0 * * * * /opt/scripts/misc/maxmisc/spaceman.sh
# Add this entry to your user's crontab using crontab -e command.

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

# IFS for safer handling of filenames and paths
IFS=$'\n\t'

#________ VARIABLES
# Source the configuration file
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

# space_path="/mnt/local/"
# thisserver="maxical"
# min_space_threshold=20
# webhook_url="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
# spaceman_logfile="${logsdir}/spaceman.log"

#________ FUNCTIONS

# Check the disk space
check_space() {
    # Get the disk space usage information for the specified path and extract the available space and usage percentage
    df_result=$(df -h --output=avail,pcent,target "$space_path" | tail -1)
    echo "$(date): DFR= $df_result" >>"$spaceman_logfile"
    free_space_percentage=$(echo "$df_result" | awk '{print 100 - $2}' | sed 's/%//')
    echo "$(date): FSP = $free_space_percentage" >>"$spaceman_logfile"
    free_space_human=$(echo "$df_result" | awk '{print $1}')
    echo "$(date): FSH = $free_space_human" >>"$spaceman_logfile"
}

# Send a notification using Apprise
send_notification() {
    # Compose the notification message with information about the server, free space, and largest subdirectory
    message="@everyone<br />**Warning!**<br />Free space on $thisserver has fallen below $min_space_threshold%.<br />Only $free_space_human remaining.<br />The largest subdirectory is $largest_subdir occupying $largest_size."

    # Send the notification message to the specified webhook URL using Apprise
    apprise --input-format=html -b "$message" -t "**Low Disk Space Alert** on $thisserver" "$webhook_url"

    # Log the notification with a timestamp in the specified log file
    echo "$(date): $message" >>"$spaceman_logfile"
}

# Find the largest subdirectory
find_largest_subdir() {
    # Get the disk space usage information for all directories under the specified path, sort by size in descending order, and extract the largest subdirectory information
    largest_subdir_info=$(du -hsx "$space_path"/* 2>/dev/null | sort -rh | head -n 1)
    echo "$(date): L_SD_Info= $largest_subdir_info" >>"$spaceman_logfile"

    largest_size=$(echo "$largest_subdir_info" | awk '{print $1}')
    echo "$(date): LG_SZ= $largest_size" >>"$spaceman_logfile"

    largest_subdir=$(echo "$largest_subdir_info" | awk '{$1=""; print $0}' | sed 's/^ *//')
    echo "$(date): LG_SD= $largest_subdir" >>"$spaceman_logfile"
}

# Evaluate the disk space and send a notification if it's below the threshold
evaluate_and_notify() {
    if [ "$free_space_percentage" -le "$min_space_threshold" ]; then
        find_largest_subdir
        send_notification
    else
        echo "Disk space is above the threshold. No notification sent."
    fi
}

#________ MAIN

check_space
evaluate_and_notify
