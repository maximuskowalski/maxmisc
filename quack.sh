#!/usr/bin/env bash
# https://github.com/maximuskowalski/maxmisc/blob/master/quack.sh

# RIP discduck

# an incremental small config files backerupperer for
# your little fu's. After learning of the death of "disco"duck I might rename this quack
# quack is a quick back up of config files and scripts from my saltbox installs.
# it is not a saltbox backup by any means.

#________ NOTES

# USE FUNCTIONS WE MAY HAVE SOME true FALSE switches
# USE .conf for VARS?
# . /opt/scripts/maxmisc/fureverso.conf
# And for a list of files to backup
# copy sample file to same dir
# filelist.txt
# MAKE DIRS FOR BACKUPS, LOGS, STUFF?
# Reduce dir depths, eg saltbox

#________ VARS ( MAY GO TO CONFIG FILE ( REPO WIDE))

source "$(dirname "$0")/maxmisc.conf"

# fileslist=filelist.txt
# filtlist=filtlist.txt
# ziplist=ziplist.txt

# qkupdir=/home/"${myusername}"/quack

# SUBSET
# qaktmpdir="${qkupdir}"/files
# qakzipsdir="${qkupdir}"/zips
# qakbakdir="${qkupdir}"/backups
# qakinfdir="${qkupdir}"/info

# qakfirstrun="${qakinfdir}"/quack.txt

# today=$(date '+%Y_%d_%m__%H_%M_%S')
# qakbakfile="${qakbakdir}"/config_backup"${today}".zip

# UPLOADER
# qakupload=true
# backupdrive=maxbackup
# thisserver=maxical
# RFLAGS="--drive-chunk-size=2048M --buffer-size 8192M"

#________ ACTIONS

# backup user crontab & grab kernel & neofetch info
# this is to test versioning and probably should not be part of script when complete
# neofetch should be config for plain text output

tempactions() {
    crontab -l >"${qaktmpdir}"/mycron
    uname -a >"${qaktmpdir}"/system.txt
    neofetch >"${qaktmpdir}"/neofetch.txt
    echo '' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    echo 'lshw info' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    sudo lshw -short >>"${qaktmpdir}"/system.txt
    echo '' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    echo 'lsblk info' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    lsblk >>"${qaktmpdir}"/system.txt
    echo '' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    echo 'df info' >>"${qaktmpdir}"/system.txt
    echo '################' >>"${qaktmpdir}"/system.txt
    df -h >>"${qaktmpdir}"/system.txt
}

#________ FUNCTIONS

# check for root runners
rooter() {
    if [ "$(whoami)" = root ]; then
        echo "Running as root or with sudo is not supported. Exiting."
        exit
    fi
}

# check for existence
checkoff() {
    ([ -d "${qkupdir}" ] || dirmaker)
    ([ -e "${qakfirstrun}" ] || setup)
    # check for zip / neofetch installs?
}

# make our destination dirs
dirmaker() {
    # mkdir -p "${qkupdir}" && sudo chown "${myusername}":"${myusername}" "${qkupdir}"
    mkdir -p {"${qkupdir}","${qaktmpdir}","${qakzipsdir}","${qakbakdir}","${qakinfdir}"} && sudo chown "${myusername}":"${myusername}" {"${qkupdir}","${qaktmpdir}","${qakzipsdir}","${qakbakdir}","${qakinfdir}"}

}

# make copies of files in "${fileslist}" or "${filtlist}"
# USE check for existence first

arrsinker() {
    ([ -e "${fileslist}" ] && filesinker)
    ([ -e "${filtlist}" ] && filtsinker)
    ([ -e "${COPYLIST}" ] && cpsinker)
    # --prune-empty-dirs ( -m )
    # -n ( for dry run )
    # --exclude="*" ( this should work from filelist)
}

filesinker() {
    rsync -a --prune-empty-dirs --files-from="${fileslist}" / "${qaktmpdir}" >/dev/null 2>&1

}

filtsinker() {
    rsync -a --prune-empty-dirs --include-from="${filtlist}" / "${qaktmpdir}" >/dev/null 2>&1
}

# test using `cp` instead of rsync, should only copy new / changed files
cpsinker() {
    while read -r file; do cp --parents --update "$file" "${qakbakdir}"; done <"${fileslist}" >/dev/null 2>&1
    # cp --parents --update -r test/1/.moo test2/
    # some loop that will do above
}

# make some zips
# config_backup.zip

# list of directories to be zipped instead of copied
dirzip() {
    ([ -e "${ziplist}" ] || echo "Error: Input file does not exist.")

    # iterate over each line in the input file
    while IFS= read -r line; do
        # check if the directory exists
        if [ -d "$line" ]; then
            # navigate to the directory
            cd "$line" || return

            # zip all files in the directory
            zip -r "${qakzipsdir}"/"${line//\//_}.zip" ./* >/dev/null 2>&1

            # navigate back to the previous directory
            cd - >/dev/null || return
        else
            echo "..."
        fi
    done <"${ziplist}"

}

zipper() {
    cd "${qkupdir}" || return
    zip -r "${qakbakfile}" files/* zips/* >/dev/null 2>&1
}

# logrotator should be in place already?

setup() {
    # create the rotator
    # rotatormator # not currently used, file rotate happens every script run
    # create the firstrun.txt file
    firstfile
    installutils
}

# test in-script rotator instead of logrotate
alternator() {
    ls -1t "${qakbakdir}"/*.zip | tail -n +8 | xargs rm >/dev/null 2>&1
    # ls -1t "${qakbakdir}"/*.zip | tail -n +6 | xargs rm
    # find "${qakbakdir}"/*.zip -mtime +10 -delete #all files more than X (10) days old
}

# current file uses dates - change back if using logrotate
rotatormator() {

    sudo bash -c 'cat > /etc/logrotate.d/quack' <<EOF
    "${qakbakfile}" {
        dateext
        rotate 35
        nocompress
        missingok
        notifempty
        extension .zip
        su ${myusername} ${myusername}
    }
EOF

}

firstfile() {
    echo "${today}" >"${qakfirstrun}"
}

installutils() {
    if hash zip 2>/dev/null; then echo "zip already installed"; else sudo apt install zip -y; fi
    if hash lshw 2>/dev/null; then echo "lshw already installed"; else sudo apt install lshw -y; fi
    if hash neofetch 2>/dev/null; then echo "neofetch already installed"; else sudo apt install neofetch -y; fi
}

# uploader ( might want a switch for this )
uploader() {
    (("${qakupload}" == true)) && rclone copy -vP "${qakbakdir}"/ "${backupdrive}":/backups/${thisserver}/quack/ --drive-chunk-size=2048M --buffer-size 8192M || return
}

# finish notification
fin() {
    echo
    echo "    **************************"
    echo "    * ---------------------- *"
    echo "    *  - backup complete! -  *"
    echo "    * ---------------------- *"
    echo "    **************************"
    echo
}

#______________ RUNLIST

rooter
checkoff # this will run dirmaker if needed
tempactions
arrsinker # rsync switches
dirzip
zipper
alternator # testing - may go back to logrotate
uploader
fin
