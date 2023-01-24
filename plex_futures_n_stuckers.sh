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

"${plexsql}" --sqlite "${plexdb}" <<END_SQL
.timeout 2000
UPDATE metadata_items SET added_at = DATETIME('now') WHERE DATETIME(added_at) > DATETIME('now');
UPDATE metadata_items SET added_at = originally_available_at WHERE added_at <> originally_available_at AND originally_available_at IS NOT NULL;
END_SQL
docker start "${plexdockername}"
#eof
