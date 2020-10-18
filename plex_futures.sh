#!/bin/sh

PLEXDOCKER=plex
PLEXDBPATH="/opt/plex/app/Plex Media Server/Plug-in Support/Databases/"

docker stop "${PLEXDOCKER}"
cp "${PLEXDBPATH}com.plexapp.plugins.library.db" "${PLEXDBPATH}com.plexapp.plugins.library.db.bak"
sqlite3 "${PLEXDBPATH}com.plexapp.plugins.library.db" <<END_SQL
.timeout 2000
UPDATE metadata_items SET added_at = DATETIME('now') WHERE DATETIME(added_at) > DATETIME('now');;;
END_SQL
docker start "${PLEXDOCKER}"
#eof
