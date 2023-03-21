#!/usr/bin/env bash
# # https://github.com/maximuskowalski/maxmisc/blob/master/backup.app.sh

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

#______________

# TODO:
# - Rename to app.backup and app.restore for better pairing
# - Support for multiple apps and non-docker apps data
# - Include necessary variables in the output message and file for restore
# - Convert to functions for better code interchangeability

IFS=$'\n\t'

#________ VARS
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

check_root() {
    if [ "$(whoami)" = root ]; then
        echo "Running as root or with sudo is not supported. Exiting."
        exit
    fi
}

stop_docker_container() {
    if [ -n "${appdockername}" ]; then
        docker stop "${appdockername}"
    else
        echo "No Docker container associated with ${appname}. Skipping container stop."
    fi
}

create_backup_directory() {
    mkdir -p "${bkupdir}"
}

create_archive() {
    tar -chzvf "${bkupdir}"/"${appname}"_"${thisserver}".tar.gz -C "${appdir}" "${appdatadir}"
}

start_docker_container() {
    if [ -n "${appdockername}" ]; then
        docker start "${appdockername}"
    else
        echo "No Docker container associated with ${appname}. Skipping container start."
    fi
}

upload_backup() {
    rclone copy -vP "${bkupdir}"/"${appname}"_"${thisserver}".tar.gz "${backupdrive}":/backups/"${thisserver}"/ "${rflags}"
}

print_archive_details() {
    echo "Uploaded archive details:"
    echo "Name: ${appname}_${thisserver}.tar.gz"
    echo "Path: ${backupdrive}:/backups/${thisserver}/"
}

backup_app() {
    stop_docker_container
    create_backup_directory
    create_archive
    start_docker_container
    upload_backup
    print_archive_details
}

main() {
    check_root
    dockerinstalled

    for app_info in "${apps[@]}"; do
        IFS="|" read -r appname appdatadir appdockername <<<"${app_info}"
        echo "Backing up ${appname}..."
        backup_app
    done
}

#________ EXECUTION

main
