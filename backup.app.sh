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
# - Make backup dir on remote a variable?

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
    local archive_name="${appname}_${thisserver}.tar.gz"
    tar -chzvfq "${bkupdir}/${archive_name}" -C "${appdir}" "${appdatadir}"
    echo "${archive_name}"
}

start_docker_container() {
    if [ -n "${appdockername}" ]; then
        docker start "${appdockername}"
    else
        echo "No Docker container associated with ${appname}. Skipping container start."
    fi
}

upload_backup() {
    echo "DEBUG: Uploading archive: ${bkupdir}/${archive_name}"
    rclone copy -vP "${bkupdir}/"${archive_name}"" "${backupdrive}":/miscbackups/"${thisserver}"/ "${rflags[@]}"
}

print_archive_details() {
    local archive_name=$1
    echo "DEBUG: Printing archive details for ${archive_name}"
    local details="Archive details for ${appname}:
    - Archive name: ${archive_name}
    - Source path: ${appdir}/${appdatadir}
    - Destination path: ${backupdrive}:/backups/${thisserver}/${archive_name}"
    all_archive_details+="${details}\n"
}

print_all_archive_details() {
    echo -e "\nAll archive details:"
    echo -e "${all_archive_details}"
}

backup_app() {
    echo "stopping docker container if needed"
    stop_docker_container
    create_backup_directory
    local archive_name
    archive_name=$(create_archive)
    start_docker_container
    upload_backup
    print_archive_details "${archive_name}"
}

main() {
    check_root

    all_archive_details=""
    for app_info in "${apps[@]}"; do
        IFS="|" read -r appname appdatadir appdockername <<<"${app_info}"
        echo "Backing up ${appname}..."
        backup_app
    done

    print_all_archive_details
}

#________ EXECUTION

main
