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
  local restoreappdatadir=$1
  restoretarget="${appdir}/${restoreappdatadir}"
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
  local appname=$1
  local donorfilename="${appname}_${donorserver}.tar.gz"
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
  local restoreappdockername=$1

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
  local appname=$1
  local donorfilename="${appname}_${donorserver}.tar.gz"
  tar -xvzf "${restoredir}/${donorfilename}" -C "${appdir}"
}

# Start the Docker container if it exists
dockstart() {
  local restoreappdockername=$1

  if [ "$dockexist" = true ]; then
    docker start "${restoreappdockername}"
  else
    echo no docker named "${restoreappdockername}" to start
  fi
}

print_restore_details() {
  local appname=$1
  local donorfilename="${appname}_${donorserver}.tar.gz"
  local details="Restore details for ${appname}:
    - Archive name: ${donorfilename}
    - Source path: ${backupdrive}:${donorfilepath}/${donorfilename}
    - Destination path: ${appdir}/${appdatadir}"
  all_restore_details+="${details}\n"
}

# Print a message indicating the restore process is complete
print_all_restore_details() {
  echo -e "\nAll restore details:"
  echo -e "${all_restore_details}"
}

# Restore the app
restore_app() {
  check_for_dirs "${restoreappdatadir}"
  pull_files "${appname}"
  dockerinstalled
  dockcheck "${restoreappdockername}"
  extractomate "${appname}"
  dockstart "${restoreappdockername}"
  print_restore_details "${appname}"
}

# Main function to run the restore script
main() {
  check_root

  for app_info in "${restore_apps[@]}"; do
    IFS="|" read -r appname restoreappdatadir restoreappdockername <<<"${app_info}"
    echo "Restoring ${appname}..."
    restore_app
  done

  print_all_restore_details
}

#________ EXECUTION

main
