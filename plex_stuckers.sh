#!/usr/bin/env bash

source "$(dirname "$0")/maxmisc.conf"

docker stop "${plexdockername}"
cd "${plexdbpath}" || return

cp "${plexdb}" "${plexdb}_${today}.bak"

([ -e "com.plexapp.plugins.library.db-shm" ] && rm com.plexapp.plugins.library.db-shm)
([ -e "rm com.plexapp.plugins.library.db-wal" ] && rm rm com.plexapp.plugins.library.db-wal)

"${plexsql}" --sqlite "${plexdb}" <<END_SQL
.timeout 2000
UPDATE metadata_items SET added_at = originally_available_at WHERE added_at <> originally_available_at AND originally_available_at IS NOT NULL;
END_SQL
docker start "${plexdockername}"
#eof
