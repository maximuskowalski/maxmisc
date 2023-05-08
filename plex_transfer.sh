#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/plex_transfer.sh

# A script to create a backup of the Plex database and metadata
# and upload it to a remote location using rclone.

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

# IFS for safer handling of filenames and paths
IFS=$'\n\t'

#________ VARIABLES
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

archive_name="" # Declare a global variable for the archive_name

#________ FUNCTIONS

# Exit if the script is running as root or with sudo
check_root() {
    if [ "$(id -u)" = 0 ]; then
        echo "Running as root or with sudo is not supported. Exiting."
        exit 1
    fi
}

check_for_dirs() {
    ([ -d "${bkupdir}" ] || create_backup_directory)
}

# Create the backup directory for the archive
create_backup_directory() {
    mkdir -p "${bkupdir}"
    cd "${bkupdir}" || exit 1
}

# Stop the Plex Docker container
stop_plex_container() {
    docker stop "${plexdockername}"
}

# Backup the Plex database
backup_plexdb() {
    cp "${plexdblocation}" "${plextrnsfrdb}"
}

# Start the Docker container associated with the app
start_docker_container() {
    docker start "${plexdockername}"
}

# Create the archive of the app's data
create_archive() {
    archive_name="plex_${plexservername}_${thisserver}.tar.gz"
    tar -chzvf "${bkupdir}/${archive_name}" "${plexmdlocation}" "${plextrnsfrdb}"
}

# Upload the backup archive to the remote location
upload_backup() {
    rclone copy -vP "${bkupdir}/${archive_name}" "${backupdrive}":/miscbackups/"${thisserver}"/ "${rflags[@]}"
}

print_archive_details() {
    local archive_size
    archive_size=$(du -sh "${bkupdir}/${archive_name}" | cut -f1)
    local time_elapsed=$((SECONDS / 60))
    echo "Backup complete"
    echo ""
    echo "Backup file: ${bkupdir}/${archive_name}"
    echo "Backup size: ${archive_size}"
    echo "Backup location: ${backupdrive}:/miscbackups/${thisserver}/"
    echo "Time elapsed: ${time_elapsed} minutes"
    echo "-_-_-_-_-_-_-"
}

# Main function to run the script
main() {
    check_root
    check_for_dirs
    stop_plex_container
    backup_plexdb
    start_docker_container
    create_archive
    upload_backup
    print_archive_details
}

#________ EXECUTION

main
