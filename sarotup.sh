#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/sarotup.sh
# an sarotate updater
# https://github.com/saltydk/SARotate

# https://docs.github.com/en/rest/reference/repos#releases

# we need to backup the existing config
# edit the current config to the new format
# replace the executable with the latest
# make sure it is +X
# profit.

set -Eeuo pipefail

#________ VARS

APP=sarotate
APPDIR=/opt

#________ DONT CHANGE

BRED="$(tput setaf 9)"   # bright red
YELLOW="$(tput setaf 3)" # yellow
RESET="$(tput sgr0)"     # reset

MNTPNT=${APPDIR}/${APP}
CONFIGFILE="${MNTPNT}/config.yaml"
NEWFIGFILE="${MNTPNT}/config.yaml.new"
APPFILE="${MNTPNT}/SARotate"

LATESTLINK="$(curl -Ls "https://api.github.com/repos/saltydk/sarotate/releases/latest" | grep browser_download_url | cut -d '"' -f 4)"

#________ FUNCTIONS

rooter() {
  if [ "$(id -u)" = 0 ]; then
    echo "##################################################################"
    echo "${BRED} Running as root or with sudo is not supported. Exiting.${RESET}"
    echo "##################################################################"
    exit 1
  fi
}

checkoff() {
  ([ ! -e "${CONFIGFILE}" ] || cp "${CONFIGFILE}" "${MNTPNT}/config.yaml.bak")
  ([ ! -e "${APPFILE}" ] || cp "${APPFILE}" "${MNTPNT}/SARotate.bak")
}

fetcher() {
  curl -JLO "${LATESTLINK}"
}

waiting() {
  read -r -p "${YELLOW}Is your new config file ready?  [Y/N] : ${RESET}" i
  case $i in
  [yY])
    echo -e "${YELLOW}OK moving on"
    echo
    ;;
  *)
    echo "${BRED}Invalid Option - this ones a yes yes"
    waiting
    ;;
  esac
}

mover() {
  chmod +x SARotate
  cp SARotate "${APPFILE}"
  cp ${NEWFIGFILE} "${CONFIGFILE}"
}

cleanup() {
  rm SARotate
}

rooter
checkoff
fetcher
waiting
mover
cleanup
