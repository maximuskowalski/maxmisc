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

# Check if the script is running as root, exit if it is
check_root() {
  if [ "$(id -u)" -eq 0 ]; then
    echo "This script should not be run as root. Please run it as a normal user with access to 'sudo' commands."
    exit 1
  fi
}

# Check for necessary directories and create them if they don't exist
check_for_dirs() {
  ([ -d "${restoredir}" ] || make_restoredir)
  ([ -d "${restoretarget}" ] || make_target)
}

# Create restore directory
make_restoredir() {
  mkdir -p "${restoredir}"
}

# Create target directory
make_target() {
  sudo mkdir -p "${restoretarget}"
  sudo chown "${USER}":"${USER}" "${restoretarget}"
  chmod 775 "${restoretarget}"
}

# Download the backup archive from the remote location
pull_files() {
  rclone copy -vP "${backupdrive}":"${donorfilepath}/${donorfilename}" "${restoredir}" "${rflags[@]}"
}

# Check if Docker is installed
dockerinstalled() {
  if [[ $(which docker) && $(docker --version) ]]; then
    dockerinst="true"
  else
    echo "docker not installed"
    dockerinst="false"
  fi
}

# Check if the Docker container exists, stop it if it does
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

# Extract the backup archive to the target directory
extractomate() {
  tar -xvzf "${restoredir}/${donorfilename}" -C "${appdir}"
}

# Start the Docker container if it exists
dockstart() {
  if [ "$dockexist" = true ]; then
    docker start "${restoreappdockername}"
  else
    echo no docker named "${restoreappdockername}" to start
  fi
}

# Print a message indicating the restore process is complete
exiting() {
  echo
  echo "restore complete"
  echo
}

# Restore the app
restore_app() {
  check_for_dirs
  pull_files
  dockerinstalled
  dockcheck
  extractomate
  dockstart
  exiting
}

# Main function to run the restore script
main() {
  check_root

  for app_info in "${restore_apps[@]}"; do
    IFS="|" read -r appname appdatadir appdockername <<<"${app_info}"
    echo "Restoring ${appname}..."
    restore_app
  done
}

#________ EXECUTION

main
