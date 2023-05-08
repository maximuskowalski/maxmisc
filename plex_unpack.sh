#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/plex_unpack.sh

# A script to restore the Plex database and metadata
# from a backup archive using rclone.

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

# IFS for safer handling of filenames and paths
IFS=$'\n\t'

#________ VARIABLES
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

# Exit if the script is running as root or with sudo
check_root() {
    if [ "$(id -u)" = 0 ]; then
        echo "Running as root or with sudo is not supported. Exiting."
        exit 1
    fi
}

# Check for necessary directories and create them if they don't exist
check_for_dirs() {
    ([ -d "${restoredir}" ] || make_restoredir)
    ([ -d "${plex_restoretarget}" ] || make_target)
}

# Create restore directory
make_restoredir() {
    mkdir -p "${restoredir}"
    cd "${restoredir}" || exit 1
}

# Create target directory
make_target() {
    sudo mkdir -p "${plex_restoretarget}"
    sudo chown "${USER}":"${USER}" "${plex_restoretarget}"
    chmod 775 "${plex_restoretarget}"
}

# Stop the Plex Docker container
stop_plex_container() {
    docker stop "${plexdockername}"
}

# Download the backup archive from the remote location
download_backup() {
    rclone copy -vP "${backupdrive}":"${donorfilepath}/${plex_restore_archive_name}" "${restoredir}" "${rflags[@]}"
}

# Extract the backup archive
extract_backup() {
    tar -xzvf "${plex_restore_archive_name}" -C /
}

# Restore the Plex database
restore_plexdb() {
    cp "${plexrstrdb}" "${plexdblocation}"
}

# Start the Plex Docker container
start_plex_container() {
    docker start "${plexdockername}"
}

print_restore_details() {
    local archive_size
    archive_size=$(du -sh "${restoredir}/${plex_restore_archive_name}" | cut -f1)
    local time_elapsed=$((SECONDS / 60))

    echo "Restore complete"
    echo ""
    echo "Restored from: ${backupdrive}:${donorfilepath}/${plex_restore_archive_name}"
    echo "Restore archive size: ${archive_size}"
    echo "Restore location: ${plex_restoretarget}"
    echo "Time elapsed: ${time_elapsed} minutes"
    echo "-_-_-_-_-_-_-"
}

# Main function to run the script
main() {
    check_root
    create_backup_directory
    stop_plex_container
    download_backup
    extract_backup
    restore_plexdb
    start_plex_container
    print_restore_details
}

#________ EXECUTION

main
