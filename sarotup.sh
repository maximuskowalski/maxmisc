#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/sarotup.sh
# an sarotate updater
# https://github.com/saltydk/SARotate

# https://docs.github.com/en/rest/reference/repos#releases

# new format now long established
# TODO merge this script with installer

# we need to backup the existing config
# edit the current config to the new format
# replace the executable with the latest
# make sure it is +X
# profit.

set -Eeuo pipefail

#________ VARS

source "$(dirname "$0")/maxmisc.conf"

# sarotatename=sarotate
# appdir=/opt

#________ DONT CHANGE

# bred="$(tput setaf 9)"   # bright red
# yellow="$(tput setaf 3)" # yellow
# reset="$(tput sgr0)"     # reset

# sarotatemntpnt=${appdir}/${sarotatename}
# CONFIGFILE="${sarotatemntpnt}/config.yaml"
# NEWFIGFILE="${sarotatemntpnt}/config.yaml.new"
# sarappfile="${sarotatemntpnt}/SARotate"

# sarlink="$(curl -Ls "https://api.github.com/repos/saltydk/sarotate/releases/latest" | grep browser_download_url | cut -d '"' -f 4)"

#________ FUNCTIONS

rooter() {
  if [ "$(id -u)" = 0 ]; then
    echo "##################################################################"
    echo "${bred} Running as root or with sudo is not supported. Exiting.${reset}"
    echo "##################################################################"
    exit 1
  fi
}

checkoff() {
  # ([ ! -e "${CONFIGFILE}" ] || cp "${CONFIGFILE}" "${sarotatemntpnt}/config.yaml.bak")
  ([ ! -e "${sarappfile}" ] || cp "${sarappfile}" "${sarotatemntpnt}/SARotate.bak")
}

fetcher() {
  curl -JLO "${sarlink}"
}

waiting() {
  read -r -p "${yellow}Is your new config file ready?  [Y/N] : ${reset}" i
  case $i in
  [yY])
    echo -e "${yellow}OK moving on"
    echo
    ;;
  *)
    echo "${bred}Invalid Option - this ones a yes yes"
    waiting
    ;;
  esac
}

mover() {
  chmod +x SARotate
  cp SARotate "${sarappfile}"
  # cp ${NEWFIGFILE} "${CONFIGFILE}"
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
