#!/usr/bin/env bash
# # https://github.com/maximuskowalski/maxmisc/blob/master/backup.app.sh

APPNAME=plex                       # name of your app - used in filename
PARENTDIR="/opt"                   # Parent dir in which backup dir is nested (docker appdata)
APPDIR="plex"                      # appdir to backup
BKUPDIR=/home/"${USER}"/appbackups # local backup dir
BKUPDRV=maxbackup                  # rclone config name of destination share drive, eg 'google'
SRVR=maxical                       # name of your server, eg hetzner01 - used in filename
THEDOCKER=plex                     # name of your app docker - to stop and start

# TODO: STAMP=$(date +%Y%m%d)

#______________

docker stop "${THEDOCKER}"

mkdir -p "${BKUPDIR}"
cd "${PARENTDIR}" || return
tar -chzvf "${BKUPDIR}"/${APPNAME}_${SRVR}.tar.gz "${APPDIR}"
rclone copy -vP "${BKUPDIR}"/${APPNAME}_${SRVR}.tar.gz "${BKUPDRV}":/backups/${SRVR}/ --drive-chunk-size=2048M --buffer-size 8192M

docker start "${THEDOCKER}"
