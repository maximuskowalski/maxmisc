#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/cropduster.sh
# Crop installer
# https://github.com/l3uddz/crop

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

#______________

# TODO:
# Grab service files? - user problem?
# config... too hard for now
# grab other xClones?
# edit crop sample config to include extra clone examples

# IFS for safer handling of filenames and paths
IFS=$'\n\t'

#________ VARS
# Source the configuration file
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

# Check if the script is run as root
check_root() {
  if [ "$(whoami)" = root ]; then
    echo "Running as root or with sudo is not supported. Exiting."
    exit
  fi
}

# Check if the crop directory exists, create it if not
check_and_create_crop_directory() {
  ([ -d "${cropmntpnt}" ] || create_crop_directory)
}

# Create the crop directory and set ownership to the current user
create_crop_directory() {
  sudo mkdir -p "${cropmntpnt}" && sudo chown "${USER}":"${USER}" "${cropmntpnt}"
}

# Fetch the required binaries and sample configuration
fetch_binaries() {
  # Download and install crop
  wget -c "${crop_latest_release_url}" -O "${cropmntpnt}"/crop
  chmod +x "${cropmntpnt}"/crop

  # Download and install lclone
  wget -c "${lclone_latest_release_url}" -O "${cropmntpnt}"/lclone
  chmod +x "${cropmntpnt}"/lclone

  # Download and install fclone
  wget -c "${fclone_latest_release_url}" -O "${cropmntpnt}"/fclone.zip
  unzip -o "${cropmntpnt}"/fclone.zip -d "${cropmntpnt}"
  rm "${cropmntpnt}"/fclone.zip
  chmod +x "${cropmntpnt}"/fclone

  # Download and install gclone
  wget -c "${gclone_latest_release_url}" -O "${cropmntpnt}"/gclone.zip
  unzip -o "${cropmntpnt}"/gclone.zip -d "${cropmntpnt}"
  rm "${cropmntpnt}"/gclone.zip
  chmod +x "${cropmntpnt}"/gclone

  # Download sample config file
  wget -c "${crop_sample_config}" -O "${cropmntpnt}"/config.yaml.sample
}

# Print helpful information about crop and the sample configuration
print_help_message() {
  echo
  echo "    For documentation see"
  echo "    https://github.com/l3uddz/crop"
  echo
  echo "    A sample configuration file is located here"
  echo "    ${cropmntpnt}/config.yaml.sample"
  echo "    Copy and edit or create ${cropmntpnt}/config.yaml"
  echo
}

# Print the final message indicating the completion of the installation
print_completion_message() {
  echo
  echo "    **************************"
  echo "    * ---------------------- *"
  echo "    * - Install completed! - *"
  echo "    * ---------------------- *"
  echo "    **************************"
  echo
}

#________ MAIN

check_root
check_and_create_crop_directory
fetch_binaries
print_help_message
print_completion_message
