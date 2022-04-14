#!/bin/bash
# https://github.com/maximuskowalski/maxmisc/blob/master/unpackplex.sh

BKUPDRV=backup        # rclone config name of backup share drive, eg 'google'

THEDOCKER=plex        # name of your plex docker

PLEXNAME=imhotep      # name of your plex server - used in filename
SRVR=hetzner01        # name of your server, eg hetzner01

BKUPDIR=/home/"${USER}"/appbackups    # local backup dir

# plex DB location, absolute path
PLEXDB="/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/com.plexapp.plugins.library.db"

BKUPDB="${BKUPDIR}/com.plexapp.plugins.library.db.trnsfrbkup"


#______________

mkdir -p "${BKUPDIR}"
cd "${BKUPDIR}" || return

docker stop "${THEDOCKER}"

rclone copy -vP "${BKUPDRV}:/backups/${SRVR}/${PLEXNAME}_${SRVR}.tar.gz" "${BKUPDIR}" --drive-chunk-size=2048M --buffer-size 8192M

tar -xzvf "${PLEXNAME}_${SRVR}.tar.gz" -C /

cp "${BKUPDB}" "${PLEXDB}"

docker start "${THEDOCKER}"

#EOF
