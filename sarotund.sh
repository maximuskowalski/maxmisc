#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/sarotund.sh
# an sarotate installer
# https://github.com/saltydk/SARotate

set -Eeuo pipefail
IFS=$'\n\t'

# Grab service files dir
# and semi config... maybe later
# systemd? maybe var

#________ VARS

source "$(dirname "$0")/maxmisc.conf"

# sarotatename=sarotate
# appdir=/opt
# sarsysdinst=true # creates systemd file and enables but does not start

#________ DONT CHANGE

# sarotatemntpnt=${appdir}/${sarotatename}

# sarotateconfig="${sarotatemntpnt}/config.yaml.sample"

# sarlink="$(curl -Ls "https://api.github.com/repos/saltydk/sarotate/releases/latest" | grep browser_download_url | cut -d '"' -f 4)"

#________ FUNCTIONS

rooter() {
  if [ "$(whoami)" = root ]; then
    echo "${BRED} Running as root or with sudo is not supported. Exiting.${RESET}"
    exit
  fi
}

checkoff() {
  ([ -d "${sarotatemntpnt}" ] || dirmkr)
}

dirmkr() {
  sudo mkdir -p "${sarotatemntpnt}" && sudo chown "${USER}":"${USER}" "${sarotatemntpnt}"
}

fetching() {
  wget -c "${sarlink}" -O ${sarotatemntpnt}/SARotate
  chmod +x ${sarotatemntpnt}/SARotate
}

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

sysdcheck() {
    ([ $sarsysdinst = true ] && sysdmaker && enabler) || :
}

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
configo
sysdcheck
messaging
fin
