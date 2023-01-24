#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/plex_transfer.sh

source "$(dirname "$0")/maxmisc.conf"

# backupdrive=backup        # rclone config name of backup share drive, eg 'google'

# plexdockername=plex        # name of your plex docker

# plexservername=imhotep      # name of your plex server - used in filename
# thisserver=hetzner01        # name of your server, eg hetzner01

# bkupdir=/home/"${USER}"/appbackups    # local backup dir

# plex DB and metadata location, absolute paths
# plexdblocation="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
# plexmdlocation="/opt/plex/Library/Application Support/Plex Media Server/Metadata"

# plextrnsfrdb="${bkupdir}/com.plexapp.plugins.library.db.trnsfrbkup"


#______________

mkdir -p "${bkupdir}"
cd "${bkupdir}" || return

docker stop "${plexdockername}"
cp "${plexdblocation}" "${plextrnsfrdb}"
docker start "${plexdockername}"

tar -chzvf "${bkupdir}/${plexservername}_${thisserver}.tar.gz" "${plexmdlocation}" "${plextrnsfrdb}"

rclone copy -vP "${bkupdir}/${plexservername}_${thisserver}.tar.gz" "${backupdrive}:/backups/${thisserver}/" --drive-chunk-size=2048M --buffer-size 8192M

echo "backup complete"
echo ""
echo "backup file: ${bkupdir}/${plexservername}_${thisserver}.tar.gz"
echo "backup location: ${backupdrive}:/backups/${thisserver}/"
echo "-_-_-_-_-_-_-"

#EOF
