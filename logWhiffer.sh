#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/logWhiffer.sh

# sniffs the latest logs and searches for a predefined string, sends a notification to advise when found.
# requires apprise.

#________ NOTES

# remember to exclude temp dir from github
# remember to exclude temp file from github
# logs?
# include details in notification
# if we are using multiple logs we need to reset the temp file each script run, rather than per dump or loop
# USER ERROR FAILURE HANDLING - tail: cannot open '/opt/cloudplow/cloudplow.log' for reading: No such file or directory
# This should be the log it came from, not the temp file. [2023-03-14 14:19:54] "googleapi: got HTTP response code 429" found in /home/max/logs/sniffedlogs.txt
# add an @ call in the notification?

# shellcheck disable=SC2154

# set -x

set -Eeuo pipefail

IFS=$'\n\t'

#________ VARS ( CONFIG FILE ( REPO WIDE))
# shellcheck source-path=SCRIPTDIR
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

# check and deny root runners
root_runner() {
    if [ $EUID -eq 0 ]; then
        echo "This script cannot be run as root."
        exit 1
    fi
}

safety_check() {
    if [ ! -d "$logsdir" ]; then
        mkdir -p "$logsdir"
    fi
    if [ ! -f "$logsdir/logWhiff.log" ]; then
        touch "$logsdir/logWhiff.log"
    fi
}

# tails the specified number of lines for each log file and checks for danger strings in the temporary file.
tail_puller() {
    # Create a temporary file to store the output of the tail command
    local temp_file="$logsdir/sniffedlogs.txt"
    touch "$temp_file"
    echo "tailpuller function" >>"$logsdir/logWhiff.log"

    # Tail the specified number of lines for each log file
    for short_name in "${!watched_logs[@]}"; do
        log_file="${watched_logs[$short_name]}"
        echo "Processing log file $log_file" >>"$logsdir/logWhiff.log"
        tail -n "$num_lines" "$log_file" >>"$temp_file"
    done

    # Check the temporary file for danger strings and send notifications if any are found
    for code in "${!danger_strings[@]}"; do
        danger_string="${danger_strings[$code]}"
        echo "Checking for danger string $danger_string" >>"$logsdir/logWhiff.log"
        if grep -q "$danger_string" "$temp_file"; then
            log_sniffer "$code" "$danger_string"
        fi
    done
}

# scrape the temp file to check for the watched phrases or danger_strings
# if true send to the message builder and notification functions
log_sniffer() {
    local code=$1
    local danger_string=$2
    local temp_file="$logsdir/sniffedlogs.txt"

    {
        echo
        "log_sniffer function"
        "danger_string: $danger_string"
        "Sending notification for $code"
    } >>"$logsdir/logWhiff.log"

    for short_name in "${!watched_logs[@]}"; do
        log_file="${watched_logs[$short_name]}"
        if grep -q "$danger_string" "$log_file"; then
            echo "Danger string found in $log_file" >>"$logsdir/logWhiff.log"
            the_message "$code" "$danger_string" "$log_file" "$short_name"
            break
        fi
    done
}

# builds the $msg for the body of our apprise notification
the_message() {
    local code="$1"
    local danger_string="$2"
    local log_file="$3"
    local short_name="$4"
    local date
    date=$(date "+%Y-%m-%d")
    local time
    time=$(date "+%H:%M:%S")
    local msg="@everyone<br />[$date $time]<br />**ERROR ALERT**<br /><br />**${thisserver}**<br />\"${danger_strings[$code]}\"<br />found in **$short_name** log file"
    {
        echo
        "the_message function"
        "$msg"
    } >>"$logsdir/logWhiff.log"
    send_notification "$msg"
}

#________ notifications

send_notification() {
    local msg="$1"

    # Check if webhook_url is set and is not a default value
    if [ -z "$webhook_url" ] || [ "$webhook_url" = "https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" ]; then
        echo "ERROR: webhook URL is not set or is invalid." >>"$logsdir/logWhiff.log"
        return 1
    fi

    # Use apprise command to send notification with HTML formatting
    echo "Sending notification: $msg" >>"$logsdir/logWhiff.log"
    apprise "$webhook_url" --title "logWhiffer" --input-format=html --body "$msg"
}

#________ RUNLIST
root_runner
safety_check
tail_puller
