#!/usr/bin/env bash

source "$(dirname "$0")/maxmisc.conf"

# plexdockername=plex
# plexdbpath="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
# plexdb="com.plexapp.plugins.library.db"
# plexsql="/opt/plexsql/Plex Media Server"

# today=$(date '+%Y_%d_%m__%H_%M_%S')

docker stop "${plexdockername}"
cd "${plexdbpath}" || return

cp "${plexdb}" "${plexdb}_${today}.bak"

([ -e "com.plexapp.plugins.library.db-shm" ] && rm com.plexapp.plugins.library.db-shm)
([ -e "rm com.plexapp.plugins.library.db-wal" ] && rm rm com.plexapp.plugins.library.db-wal)

"${plexsql}" --sqlite "${plexdb}" <<END_SQL
.timeout 2000
UPDATE metadata_items SET added_at = DATETIME('now') WHERE DATETIME(added_at) > DATETIME('now');
END_SQL
docker start "${plexdockername}"
#eof
