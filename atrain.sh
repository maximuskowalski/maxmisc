#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/atrain.sh
# An A-Train installer

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

IFS=$'\n\t'

#________ VARS
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

# Check for root runners
check_root() {
  if [ "$(whoami)" = root ]; then
    printf "Running as root or with sudo is not supported. Exiting.\n"
    exit
  fi
}

# Check if directories and files exist
check_resources() {
  ([ -d "${atrainmntpnt}" ] || create_directory)
  ([ -e "${atrainconfig}" ] || create_config)
}

# Create directory if it doesn't exist
create_directory() {
  sudo mkdir -p "${atrainmntpnt}" && sudo chown "${myusername}":"${myusername}" "${atrainmntpnt}" && sudo chmod 775 "${atrainmntpnt}"
}

# Create configuration file if it doesn't exist
create_config() {
  cat >"${atrainconfig}" <<EOF
# a-train.toml
[autoscan]
# Replace the URL with your Autoscan URL.
url = "http://autoscan:3030"
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

# Pull A-Train Docker image
pull_docker_image() {
  docker image pull ghcr.io/m-rots/a-train:"${atrainimagetag}"
}

# Run A-Train Docker container
run_docker_container() {
  docker run -d \
    --name "${atrainname}" \
    --volume "${atrainmntpnt}":/data \
    --user $UID \
    --network="${network}" \
    --network-alias="${atrainname}" \
    --restart unless-stopped \
    ghcr.io/m-rots/a-train
}

# Stop A-Train Docker container
stop_docker_container() {
  docker stop "${atrainname}"
  printf "...A-Train docker has been stopped for configuration\n"
}

# Display link information and messages
show_messages() {
  printf "\n    A-Train documentation:\n    https://github.com/m-rots/a-train\n\n"
  printf "    Autoscan documentation:\n    https://github.com/Cloudbox/autoscan\n\n"
  printf "    Your configuration file is located here:\n    %s/a-train.toml\n" "${atrainmntpnt}"
  printf "    Remember to add a service account\n\n"
  printf "    To start A-Train after configuration is completed...\n    docker start %s\n" "${atrainname}"
}

#________ RUNLIST

check_root
check_resources
pull_docker_image
run_docker_container
stop_docker_container
show_messages
