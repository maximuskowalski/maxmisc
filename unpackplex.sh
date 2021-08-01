#!/bin/bash
# https://github.com/maximuskowalski/maxmisc/blob/master/unpackplex.sh

PLEXNAME=imhotep  # name of your plex server - used in filename
BKUPDRV=maxbackup # rclone config name of backup share drive, eg 'google'
SRVR=maxical      # name of your server, eg hetzner01
THEDOCKER=plex    # name of your plex docker

#______________

mkdir -p /home/"${USER}"/plexbackups
cd /home/"${USER}"/plexbackups || return

docker stop "${THEDOCKER}"

rclone copy -vP "${BKUPDRV}":/backups/${SRVR}/${PLEXNAME}_${SRVR}.tar.gz /home/"${USER}"/plexbackups/ --drive-chunk-size=2048M --buffer-size 8192M
tar -xzvf plextnsfr.tar.gz -C /

docker start "${THEDOCKER}"
