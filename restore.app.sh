#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/restore.app.sh

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

# TODO: If using ${USER} then we should eliminate root runners
# confirm rflags expand properly

IFS=$'\n\t'

#________ VARS
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#______________ FUNCTIONS

check_for_dirs() {
  ([ -d "${restoredir}" ] || make_restoredir)
  ([ -d "${restoretarget}" ] || make_target)
}

make_restoredir() {
  mkdir -p "${restoredir}"
}

make_target() {
  sudo mkdir -p "${restoretarget}"
  sudo chown "${USER}":"${USER}" "${restoretarget}"
  chmod 775 "${restoretarget}"
}

pull_files() {
  rclone copy -vP "${backupdrive}":"${donorfilepath}/${donorfilename}" "${restoredir}" "${rflags}"
}

dockerinstalled() {
  if [[ $(which docker) && $(docker --version) ]]; then
    dockerinst="true"
  else
    echo "docker not installed"
    dockerinst="false"
  fi
}

# -q = quiet, show ID only
# -f = filter output based on conditions provided
# TODO: The name filter matches on all or part of a container’s name.
# TODO: how to deal with no docker at all causing command failure
# shellcheck disable=SC1073
dockcheck() {
  if [ $dockerinst = true ] && [ -n "${restoreappdockername}" ]; then
    if [ "$(docker ps -a -q -f name="${restoreappdockername}")" ]; then
      dockexist="true"
      docker stop "${restoreappdockername}"
    else
      dockexist="false"
      echo "No Docker container named '${restoreappdockername}' running"
    fi
  else
    dockexist="false"
    echo "Docker not installed or no container name provided"
  fi
}

extractomate() {
  tar -xvzf "${restoredir}/${donorfilename}" -C "${appdir}"
}

dockstart() {
  if [ "$dockexist" = true ]; then
    docker start "${restoreappdockername}"
  else
    echo no docker named "${restoreappdockername}" to start
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
