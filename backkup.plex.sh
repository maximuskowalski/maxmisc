#!/bin/bash
# https://github.com/maximuskowalski/maxmisc

PLEXNAME=imhotep                                                                                                          # name of your plex server - used in filename
PLEXDB="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db" # plex DB location
PLEMMD="/opt/plex/Library/Application Support/Plex Media Server/Metadata"                                                 # metadata location
BKUPDRV=maxbackup                                                                                                         # rclone config name of destination share drive, eg 'google'
SRVR=maxical                                                                                                              # name of your server, eg hetzner01
THEDOCKER=plex                                                                                                            # name of your plex docker

#______________

mkdir -p /home/"${USER}"/plexbackups
cd /home/"${USER}"/plexbackups || return

docker stop "${THEDOCKER}"

cp "${PLEXDB}" "${PLEXDB}.trnsfrbkup"
tar -chzvf /home/"${USER}"/plexbackups/${PLEXNAME}_${SRVR}.tar.gz "${PLEMMD}" "${PLEXDB}"

rclone copy -vP /home/"${USER}"/plexbackups/${PLEXNAME}_${SRVR}.tar.gz "${BKUPDRV}":/backups/${SRVR}/ --drive-chunk-size=2048M --buffer-size 8192M

docker start "${THEDOCKER}"
