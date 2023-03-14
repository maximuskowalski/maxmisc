#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/plex_unpack.sh

source "$(dirname "$0")/maxmisc.conf"

# backupdrive=backup        # rclone config name of backup share drive, eg 'google'
# plexdockername=plex        # name of your plex docker
# plexbuservername=imhotep      # name of your plex server - used in filename
# bufromserver=hetzner01        # name of your server, eg hetzner01
# bkupdir=/home/"${USER}"/appbackups    # local backup dir
# plex DB location, absolute path
# plexdblocation="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
# plextrnsfrdb="${bkupdir}/com.plexapp.plugins.library.db.trnsfrbkup"


#______________

mkdir -p "${bkupdir}"
cd "${bkupdir}" || return

docker stop "${plexdockername}"

rclone copy -vP "${backupdrive}:/backups/${bufromserver}/${plexbuservername}_${bufromserver}.tar.gz" "${bkupdir}" --drive-chunk-size=2048M --buffer-size 8192M

tar -xzvf "${plexbuservername}_${bufromserver}.tar.gz" -C /

cp "${plextrnsfrdb}" "${plexdblocation}"

docker start "${plexdockername}"

#EOF
