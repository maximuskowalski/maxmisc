#!/bin/sh
docker stop plex
cp "/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" "/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db.bak"
#
sqlite3 "/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" <<END_SQL
.timeout 2000
UPDATE metadata_items SET added_at=originally_available_at WHERE added_at <> originally_available_at AND originally_available_at IS NOT NULL;;
END_SQL
docker start plex
#eof
