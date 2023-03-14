# maxmisc

This branch is currently in mid-rewrite and some things may not work until it is merged into master.

Misc scripts and tools. Undocumented scripts probably do what I need them to but aren't finished yet.

## Install

I personally use a scripts directory in '/opt' but many people use their home directory.
Change directory to where you wish to clone:

```shell
cd /opt/scripts/misc
```

Clone the repository from GitHub and navigate into the cloned directory:

```sh
git clone https://github.com/maximuskowalski/maxmisc.git
cd maxmisc
# switch branches to use the dev branch
git checkout varConvert
```

After cloning the repository, make sure that the scripts are executable by running the following command:

```sh
chmod +x *.sh
```

Make a copy of the config file and edit required sections. See below for variable descriptions.

```sh
cp maxmisc.conf.sample maxmisc.conf

# use nano or your favourite editor
nano maxmisc.conf
```

Once you have made the scripts executable, and provided the required variables you can run most scripts manually using the following command:

```sh
./scriptName.sh
```

Note that each script requires certain variables to be set before it can run properly. These variables should be shown in the readme under each script heading.

That's it! With these steps, you should now be able to run sportSort on your system. If you run into any issues during installation or setup, don't hesitate to consult the README or reach out to the project's contributors for assistance.

## The Scripts

### atrain.sh

Installs atrain via docker.

### backup.app.sh

Backs up an app directory for transfer or backup.

### cropduster.sh

Installs crop.

### logWhiffer.sh

logWhiffer is a bash script designed to monitor log files for specific danger strings and send notifications via Apprise. The script reads configuration data from a separate file (maxmisc.conf) that includes log file paths, danger strings, and the Apprise webhook URL.

logWhiffer uses tail to extract a specified number of lines from each log file and saves them to a temporary file. It then searches this temporary file for each danger string and sends a notification via the specified webhook URL if a danger string is found.

To use logWhiffer, simply place the logWhiffer.sh and maxmisc.conf files in the same directory, modify the configuration file to suit your needs, and run the script. To monitor a logfile set a cronjob to run the script on an interval. Think about the number of lines you want to read and the time interval. If the number of lines is too great or the interval too short you will experience repeat notifications.

#### maxmisc.conf

maxmisc.conf is the configuration file for logWhiffer. Edit the logWhiffer section of this file prior to running the logWhiffer script. This file contains the following configurable parameters:

```conf
#________for LOGWHIFFER.sh

# Array of log files to watch
declare -A watched_logs=(
    ["crop"]="/opt/crop/activity.log"
    ["cloudplow"]="/opt/cloudplow/cloudplow.log"
    ["autoscan"]="/opt/autoscan/activity.log"

)

# Array of danger strings to look for in log files
declare -A danger_strings=(
    ["Google API 429"]="googleapi: got HTTP response code 429"
    ["ACME cert error"]="Unable to obtain ACME certificate for domains"
    ["fatality"]="fatal"
)

num_lines=100                # Number of lines to tail
logsdir="/home/${USER}/logs" # Directory for storing temporary files and logs

# URL for apprise notification
webhook_url="https://discord.com/api/webhooks/xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

- `watched_logs`: an associative array that maps a short name to a log file. The short name is used in the notification message to identify which log file the danger string was found in. Add your log files to this array with a short name that is easy to remember and the full path to the log file.
- `danger_strings`: an associative array that maps a short name for the danger string to look for in the log file. Add your danger strings to this array with a short name that is easy to remember and the exact string that should be searched for in the log file. Be careful with vague terms like "error" as you might find it appear in logs for valid processes like `error check` and so on. This potentially means a great many notifications.
- `num_lines`: the number of lines to tail from each log file.
- `logsdir`: the directory where temporary files and logs will be stored. You can change this to any directory that you prefer.
- `webhook_url`: the URL for the Apprise notification. Change this to your own webhook URL.

After you have edited the logWhiffer section, save the maxmisc.conf file and run the logWhiffer script manually to confirm it is working.

### pleanse.sh

An plex cleaner.

### plex_futures_n_stuckers.sh

Plex futures and plex stuckers in the same script.

### plex_futures.sh

Resets date added to plex to now if item was added as a future date.
Set DB Path and docker name variables before execution.

### plex_stuckers.sh

Resets date added to plex to airdate or premiere date.
Set DB Path and docker name variables before execution.

### plex_transfer.sh

Use on the donor end to transfer a plex db to another instance.

### plex_unpack.sh

Use on the receiving end when you transfer a plex db to another instance.

### quack.sh

A quick backup script

### restore.app.sh

Use to restore an app backed up using backup.app.sh.

### sarotund.sh

Use to install saRotate.

### sarotup.sh

Use to update saRotate.

### strapon.sh

Bootstrap an ubuntu server with my common enough tasks that I have a script ready to go. Kind of specific.

### wanchors.sh

Watches anchor files. If anchors are missing will shut down docker apps like plex to prevent library being emptied.
Use cron to run script at desired interval, eg minutely. Use wanchplus.sh to also restart those dockers and the merger.

`* * * * * /home/max/scripts/wanchors.sh`

### wanchplus.sh
