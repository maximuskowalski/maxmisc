#!/usr/bin/env bash
# # https://github.com/maximuskowalski/maxmisc/blob/master/backup.app.sh

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

#______________

# TODO:
# - Rename to app.backup and app.restore for better pairing
# x Support for multiple apps and non-docker apps data
# x Include necessary variables in the output message and file for restore
# x Convert to functions for better code interchangeability
# - Make backup dir on remote a variable?
# - add date / timestamps? Or move existing files on remote into datestamped dirs

IFS=$'\n\t'

#________ VARS
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

# Check if the script is running as root or with sudo, exit if it is
check_root() {
    if [ "$(whoami)" = root ]; then
        echo "Running as root or with sudo is not supported. Exiting."
        exit
    fi
}

# Stop the Docker container associated with the app
stop_docker_container() {
    if [ -n "${appdockername}" ]; then
        echo " stopping ${appdockername}"
        docker stop "${appdockername}"
    else
        echo "No Docker container associated with ${appname}. Skipping container stop."
    fi
}

# Create the backup directory for the archive
create_backup_directory() {
    mkdir -p "${bkupdir}"
}

# Create the archive of the app's data
create_archive() {
    local archive_name="${appname}_${thisserver}.tar.gz"
    tar -czf "${bkupdir}/${archive_name}" -C "${appdir}" "${appdatadir}"
    echo "${archive_name}"
}

# Start the Docker container associated with the app
start_docker_container() {
    if [ -n "${appdockername}" ]; then
        echo " starting ${appdockername}"
        docker start "${appdockername}"
    else
        echo "No Docker container associated with ${appname}. Skipping container start."
    fi
}

# Upload the backup archive to the remote location
upload_backup() {
    rclone copy -vP "${bkupdir}/""${archive_name}""" "${backupdrive}":/miscbackups/"${thisserver}"/ "${rflags[@]}"
}

# Print the archive details for the app
print_archive_details() {
    local archive_name=$1
    local details="Archive details for ${appname}:
    - Archive name: ${archive_name}
    - Source path: ${appdir}/${appdatadir}
    - Destination path: ${backupdrive}:/miscbackups/${thisserver}/${archive_name}"
    all_archive_details+="${details}\n"
}

# Print the archive details for all apps
print_all_archive_details() {
    echo -e "\nAll archive details:"
    echo -e "${all_archive_details}"
}

# Perform the backup process for an app
backup_app() {
    stop_docker_container
    create_backup_directory
    archive_name=$(create_archive)
    start_docker_container
    upload_backup
    print_archive_details "${archive_name}"
}

# Main function to run the script
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
