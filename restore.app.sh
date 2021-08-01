#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/restore.app.sh

#________ VARS

PARENTDIR="/opt"          # Parent dir in which backup dir is nested (docker appdata)
APPDIR="plex"             # appdir to backup
RESTOREDIR=~/apprestore   # local dir to save tar for restore
BKUPDRV=maxbackup         # rclone config name of destination share drive, eg 'google'
FILEPATH=/backups/maxical # Path on rclone remote to the file
FILENAME=appname.tar.gz   # Name of file to restore
THEDOCKER=plex            # name of your app docker - to stop and start

TARGET="${PARENTDIR}/${APPDIR}"
RFLAGS="--drive-chunk-size=2048M --buffer-size 8192M"
#______________ FUNCTIONS

check_for_dirs() {
  ([ -d "${RESTOREDIR}" ] || make_restoredir)
  ([ -d "${TARGET}" ] || make_target)
}

make_restoredir() {
  mkdir -p "${RESTOREDIR}"
}

make_target() {
  sudo mkdir -p "${TARGET}"
  sudo chown "${USER}":"${USER}" "${TARGET}"
  chmod 775 "${TARGET}"
}

pull_files() {
  rclone copy -vP "${BKUPDRV}":"${FILEPATH}/${FILENAME}" "${RESTOREDIR}" "${RFLAGS}"
}

dockerinstalled() {
  if [[ $(which docker) && $(docker --version) ]]; then
        DOCKERINST="true"
  else
        echo "docker not installed"
        DOCKERINST="false"
fi
}

# -q = quiet, show ID only
# -f = filter output based on conditions provided
# TODO: The name filter matches on all or part of a container’s name.
# TODO: how to deal with no docker at all causing command failure
# shellcheck disable=SC1073
dockcheck() {
    if [ $DOCKERINST = true ]; then
       if [ "$(docker ps -a -q -f name=${THEDOCKER})" ]; then
            DOCKEXIST="true"
            docker stop ${THEDOCKER}
    else
        DOCKEXIST="false"
        echo no docker named ${THEDOCKER} running
    fi
}

extractomate() {
  tar -xvzf "${RESTOREDIR}"\/"${FILENAME}" -C "${PARENTDIR}"
}

dockstart() {
    if [ $DOCKEXIST = true ]; then
        docker start ${THEDOCKER}
    else
        echo no docker named ${THEDOCKER} to start
    fi
}

exiting() {
    echo
    echo "restore complete"
    echo
}

#______________ SET LIST

check_for_dirs
pullfiles
dockerinstalled
dockcheck
extractomate
dockstart
exiting
