#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/atrain.sh
# an A-Train installer

set -Eeuo pipefail
IFS=$'\n\t'

#________ VARS

source "$(dirname "$0")/maxmisc.conf"

# atrainname=atrain
# appdir=/opt
# network=saltbox

#________ DONT CHANGE

# atrainimagetag=latest
# atrainmntpnt=${appdir}/${atrainname}
# atrainconfig="${atrainmntpnt}/a-train.toml"

#________ FUNCTIONS

checkoff() {
  ([ -d "${atrainmntpnt}" ] || dirmkr)
  ([ -e ${atrainconfig} ] || configo)
}

dirmkr() {
  sudo mkdir -p "${atrainmntpnt}" && sudo chown "${USER}":"${USER}" "${atrainmntpnt}"
}

# let user complete - no var replacing
# use heredoc instead of var

configo() {
  cat >"${atrainconfig}" <<EOF
# a-train.toml
[autoscan]
# Replace the URL with your Autoscan URL.
url = "http://localhost:3030"
username = "hello there"
password = "general kenobi"

[drive]
# Path to the Service Account key file,
# relative to the current working directory ('/data' on Docker).
account = "./account.json"
# One or more Shared Drive IDs
drives = ["0A1xxxxxxxxxUk9PVA", "0A2xxxxxxxxxUk9PVA"]
EOF
}

tugger() {
  docker image pull ghcr.io/m-rots/a-train:${atrainimagetag}
}

dockery() {
  docker run -d \
    --name "${atrainname}" \
    --volume "${atrainmntpnt}":/data \
    --user $UID \
    --network="${network}" \
    --network-alias="${atrainname}" \
    --restart unless-stopped \
    ghcr.io/m-rots/a-train
}

dockstop() {
  docker stop "${atrainname}"
  echo "...A-Train docker has been stopped for configuration"
}

messaging() {
  echo
  echo "    You must be running the cloudb0x/autoscan:bernard-rs docker image"
  echo "    for A-Train events to be accepted as triggers"
  echo
  echo "    A-Train initial documentation:"
  echo "    https://gist.github.com/m-rots/f345fd2cfc44585266b620feb9fbd612"
  echo
  echo "    A-Train Autoscan documentation:"
  echo "    https://github.com/Cloudbox/autoscan/tree/bernard-rs#a-train"
  echo
  echo "    your configuration is files is located here"
  echo "    ${atrainmntpnt}/a-train.toml"
  echo "    remember to add a service account"
  echo
  echo "    to start A-Train after configuration is completed..."
  echo "    docker start ${atrainname}"
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

checkoff
tugger
dockery
dockstop
messaging
fin
