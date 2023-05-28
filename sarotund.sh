#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/sarotund.sh
# an sarotate installer
# https://github.com/saltydk/SARotate

#________ NOTES
# Grab service files dir
# and semi config... maybe later
# systemd? maybe var

# shellcheck disable=SC2154

#________ DEV
# set -x
# set -Eeuo pipefail

# IFS for safer handling of filenames and paths
IFS=$'\n\t'

#________ VARIABLES
# shellcheck source=/dev/null
source "$(dirname "$0")/maxmisc.conf"

#________ FUNCTIONS

# Exit if the script is running as root or with sudo
check_root() {
  if [ "$(id -u)" = 0 ]; then
    echo "Running as root or with sudo is not supported. Exiting."
    exit 1
  fi
}

# Check if the SARotate dir exists and create it if necessary
checkoff() {
  ([ -d "${sarotatemntpnt}" ] || dirmkr)
}

# Create SARotate directory and set ownership
dirmkr() {
  sudo mkdir -p "${sarotatemntpnt}" && sudo chown "${USER}":"${USER}" "${sarotatemntpnt}"
}

# Download SARotate from the latest GitHub release
fetching() {
  wget -c "${sarlink}" -O "${sarotatemntpnt}"/SARotate
  chmod +x "${sarotatemntpnt}"/SARotate
}

# Generate a sample SARotate configuration file
configo() {
  cat >"${sarotateconfig}" <<EOF
rclone:
  rclone_config: "/home/${USER}/.config/rclone/rclone.conf"
  rc_user: "user"
  rc_pass: "pass"
  sleeptime: 300

remotes:
  '/opt/sa':
    seedbox-drive: localhost:5575
  '/opt/sa2':
    Movies: localhost:5575
    Movies-4K: localhost:5575
    Movies-Danish: localhost:5575
    TV: localhost:5575
    TV-4K: localhost:5575
    TV-Anime: localhost:5575

notification:
  errors_only: y
  apprise:
    - 'discord://<webhook>'
EOF
}

# Check if systemd is enabled and create the necessary files and enable the service
sysdcheck() {
  ([ "$sarsysdinst" = true ] && sysdmaker && enabler) || :
}

# Create and enable the SARotate systemd service and timer
sysdmaker() {
  sudo bash -c 'cat > /etc/systemd/system/sarotate.service' <<EOF
# /etc/systemd/system/sarotate.service
[Unit]
Description=sarotate
After=network-online.target

[Service]
User=${USER}
Group=${USER}
Type=simple
WorkingDirectory=${sarotatemntpnt}
ExecStart=${sarotatemntpnt}/SARotate
ExecStartPre=/bin/sleep 30
Restart=always
RestartSec=10

[Install]
WantedBy=default.target

EOF

  sudo bash -c 'cat > /etc/systemd/system/sarotate.timer' <<EOF
# /etc/systemd/system/sarotate.timer
[Unit]
Description=sarotate boot delay

[Timer]
OnBootSec=10min

[Install]
WantedBy=timers.target

EOF
}

# Enable the SARotate systemd service and timer, and reload the daemon
enabler() {
  sudo systemctl enable sarotate.service && sudo systemctl enable sarotate.timer && sudo systemctl daemon-reload
  echo
  echo
  echo
  echo "    systemd file created and enabled"
  echo "    WARNING: SARotate service will be"
  echo "    started on the next reboot."
  echo "    or after editing and comfirming valid config"
  echo "    to start the system service manually now "
  echo "    sudo systemctl start sarotate.service"
}

# Display information on how to use and configure SARotate
messaging() {
  echo
  echo "    For documentation see"
  echo "    https://github.com/saltydk/SARotate"
  echo
  echo "    a sample configuration is files is located here"
  echo "    ${sarotatemntpnt}/config.yaml.sample"
  echo "    copy and edit or create ${sarotatemntpnt}/config.yaml"
  echo "    before attempting to start"
  echo
}

# Display a message indicating the installation is complete
fin() {
  echo
  echo "    **************************"
  echo "    * ---------------------- *"
  echo "    * - install completed! - *"
  echo "    * ---------------------- *"
  echo "    **************************"
  echo
}

main() {
  rooter
  checkoff
  fetching
  configo
  sysdcheck
  messaging
  fin
}

#________ EXECUTION

main
