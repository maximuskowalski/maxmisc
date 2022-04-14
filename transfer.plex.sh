#!/bin/bash
# https://github.com/maximuskowalski/maxmisc/blob/master/transfer.plex.sh

BKUPDRV=backup        # rclone config name of backup share drive, eg 'google'

THEDOCKER=plex        # name of your plex docker

PLEXNAME=imhotep      # name of your plex server - used in filename
SRVR=hetzner01        # name of your server, eg hetzner01

BKUPDIR=/home/"${USER}"/appbackups    # local backup dir

# plex DB and metadata location, absolute paths
PLEXDB="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"
PLEMMD="/opt/plex/Library/Application Support/Plex Media Server/Metadata"

BKUPDB="${BKUPDIR}/com.plexapp.plugins.library.db.trnsfrbkup"


#______________

mkdir -p "${BKUPDIR}"
cd "${BKUPDIR}" || return

docker stop "${THEDOCKER}"
cp "${PLEXDB}" "${BKUPDB}"
docker start "${THEDOCKER}"

tar -chzvf "${BKUPDIR}/${PLEXNAME}_${SRVR}.tar.gz" "${PLEMMD}" "${BKUPDB}"

rclone copy -vP "${BKUPDIR}/${PLEXNAME}_${SRVR}.tar.gz" "${BKUPDRV}:/backups/${SRVR}/" --drive-chunk-size=2048M --buffer-size 8192M

echo "backup complete"
echo ""
echo "backup file: ${BKUPDIR}/${PLEXNAME}_${SRVR}.tar.gz"
echo "backup location: ${BKUPDRV}:/backups/${SRVR}/"
echo "-_-_-_-_-_-_-"

#EOF
