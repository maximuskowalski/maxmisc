#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/plex_db_repair.sh

# This script vacuums and reindexes plexdb to repair some minor corruption types.

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

# Vacuum and reindex DB
vacuum_reindex_plex_db() {
    "${plexsql}" --sqlite "${plexdb}" <<END_SQL
.timeout ${sql_timeout}
VACUUM;
REINDEX;
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
    vacuum_reindex_plex_db
    start_plex_container
}

#________ EXECUTION
# Call the main function
main
