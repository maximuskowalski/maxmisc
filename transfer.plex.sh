#!/bin/bash
# https://github.com/maximuskowalski/maxmisc/blob/master/transfer.plex.sh

PLEXNAME=imhotep                                                                                                          # name of your plex server - used in filename
PLEXDB="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" # plex DB location
PLEMMD="/opt/plex/Library/Application Support/Plex Media Server/Metadata"                                                 # metadata location
BKUPDIR=/home/"${USER}"/appbackups                                                                                        # local backup dir
BKUPDB="${BKUPDIR}/com.plexapp.plugins.library.db.trnsfrbkup"
BKUPDRV=backup                                                                                                            # rclone config name of destination share drive, eg 'google'
SRVR=mk700                                                                                                                # name of your server, eg hetzner01
THEDOCKER=plex                                                                                                            # name of your plex docker

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
