#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/cropduster.sh
# a crop installer
# https://github.com/l3uddz/crop

set -Eeuo pipefail
IFS=$'\n\t'

# Grab service files? - user problem?
# config... too hard for now

#________ VARS

APP=crop
APPDIR=/opt

#________ DONT CHANGE

MNTPNT=${APPDIR}/${APP}

#________ FUNCTIONS

rooter() {
    if [ "$(whoami)" = root ]; then
        echo "${BRED} Running as root or with sudo is not supported. Exiting.${RESET}"
        exit
    fi
}

checkoff() {
  ([ -d "${MNTPNT}" ] || dirmkr)
}

dirmkr() {
  sudo mkdir -p "${MNTPNT}" && sudo chown "${USER}":"${USER}" "${MNTPNT}"
}

fetching() {
  wget  -c https://github.com/l3uddz/crop/releases/download/v1.0.0/crop_v1.0.0_linux_amd64 -O ${MNTPNT}/crop
  chmod +x ${MNTPNT}/crop
  wget  -c https://raw.githubusercontent.com/maximuskowalski/getw/main/files/lclone -O ${MNTPNT}/lclone
  chmod +x ${MNTPNT}/lclone
  wget  -c https://raw.githubusercontent.com/maximuskowalski/getw/main/files/crop_config_sample.yml -O ${MNTPNT}/config.yaml.sample
  }

messaging() {
  echo
  echo "    For documentation see"
  echo "    https://github.com/l3uddz/crop"
  echo
  echo "    a sample configuration is files is located here"
  echo "    ${MNTPNT}/config.yaml.sample"
  echo "    copy and edit or create ${MNTPNT}/config.yaml"
  echo
}

fin() {
  echo
  echo "    **************************"
  echo "    * ---------------------- *"
  echo "    * - install completed! - *"
  echo "    * ---------------------- *"
  echo "    **************************"
  echo
}

#________ RUNLIST

rooter
checkoff
fetching
messaging
fin
