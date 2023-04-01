#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/plex_futures.sh

# This script corrects Plex items that have an incorrect added date in the future.

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

#________ FUNCTIONS
# Stop the Plex Docker container
stop_plex_container() {
    docker stop "${plexdockername}"
}

# Backup the Plex database
backup_plex_db() {
    cd "${plexdbpath}" || return
    cp "${plexdb}" "${plexdb}_${today}${backup_suffix}"
}

# Remove the SQLite journal files from the Plex database directory
remove_sqlite_journals() {
    cd "${plexdbpath}" || return
    rm -f com.plexapp.plugins.library.db-shm
    rm -f com.plexapp.plugins.library.db-wal
}

# Update the added_at timestamp of Plex media items to the current date and time
update_plex_media_timestamps() {
    "${plexsql}" --sqlite "${plexdb}" <<END_SQL
.timeout ${sql_timeout}
UPDATE metadata_items SET added_at = DATETIME('now') WHERE DATETIME(added_at) > DATETIME('now');
END_SQL
}

# Start the Plex Docker container
start_plex_container() {
    docker start "${plexdockername}"
}

# Main function
main() {
    stop_plex_container
    backup_plex_db
    remove_sqlite_journals
    update_plex_media_timestamps
    start_plex_container
}

#________ EXECUTION
# Call the main function
main
