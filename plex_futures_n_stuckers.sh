#!/usr/bin/env bash

PLEXDOCKER=plex
PLEXDBPATH="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/"
PLEXDB="com.plexapp.plugins.library.db"
PLEXSQL="/opt/plexsql/Plex Media Server"

TODAY=$(date '+%Y_%d_%m__%H_%M_%S')

docker stop "${PLEXDOCKER}"
cd "${PLEXDBPATH}" || return

cp "${PLEXDB}" "${PLEXDB}_${TODAY}.bak"

"${PLEXSQL}" --sqlite "${PLEXDB}" <<END_SQL
.timeout 2000
UPDATE metadata_items SET added_at = DATETIME('now') WHERE DATETIME(added_at) > DATETIME('now');
UPDATE metadata_items SET added_at = originally_available_at WHERE added_at <> originally_available_at AND originally_available_at IS NOT NULL;
END_SQL
docker start "${PLEXDOCKER}"
#eof
