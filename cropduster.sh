#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/cropduster.sh
# a crop installer
# https://github.com/l3uddz/crop

set -Eeuo pipefail
IFS=$'\n\t'

# Grab service files? - user problem?
# config... too hard for now

#________ VARS
source "$(dirname "$0")/maxmisc.conf"

# cropname=crop
# appdir=/opt

#________ DONT CHANGE

# cropmntpnt=${appdir}/${cropname}

#________ FUNCTIONS

rooter() {
    if [ "$(whoami)" = root ]; then
        echo " Running as root or with sudo is not supported. Exiting."
        exit
    fi
}

checkoff() {
  ([ -d "${cropmntpnt}" ] || dirmkr)
}

dirmkr() {
  sudo mkdir -p "${cropmntpnt}" && sudo chown "${USER}":"${USER}" "${cropmntpnt}"
}

fetching() {
  wget  -c https://github.com/l3uddz/crop/releases/download/v1.0.1/crop_v1.0.1_linux_amd64 -O ${cropmntpnt}/crop
  chmod +x ${cropmntpnt}/crop
  wget  -c https://raw.githubusercontent.com/maximuskowalski/getw/main/files/lclone -O ${cropmntpnt}/lclone
  chmod +x ${cropmntpnt}/lclone
  wget  -c https://raw.githubusercontent.com/maximuskowalski/getw/main/files/crop_config_sample.yml -O ${cropmntpnt}/config.yaml.sample
  }

messaging() {
  echo
  echo "    For documentation see"
  echo "    https://github.com/l3uddz/crop"
  echo
  echo "    a sample configuration is files is located here"
  echo "    ${cropmntpnt}/config.yaml.sample"
  echo "    copy and edit or create ${cropmntpnt}/config.yaml"
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
