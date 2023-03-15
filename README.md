# maxmisc

Welcome to the `maxmisc` repository, a collection of miscellaneous scripts and tools to simplify your life! This branch is currently undergoing a rewrite, so some things may not work until it's merged into the master branch. The undocumented scripts might serve their purpose but are still under development.

## Installation

You can choose where you'd like to store your scripts. Some people prefer to use a dedicated directory in `/opt`, while others use their home directory. In this example, we'll use `/opt/scripts/misc` as our directory.

1. **Change directory to where you want to clone the repo:**

   ```sh
   cd /opt/scripts/misc
   ```

2. **Clone the repository from GitHub and navigate into the cloned directory:**

   ```sh
   git clone https://github.com/maximuskowalski/maxmisc.git
   cd maxmisc
   # switch branches to use the dev branch
   git checkout varConvert
   ```

3. **Ensure the scripts are executable by running the following command:**

   ```sh
   chmod +x *.sh
   ```

4. **Create a copy of the config file and edit the required sections. See the variable descriptions below for guidance:**

   ```sh
   cp maxmisc.conf.sample maxmisc.conf

   # use nano or your preferred text editor
   nano maxmisc.conf
   ```

5. **Running the scripts manually:**
    After configuring the scripts, you can execute them manually using the following command:

   ```sh
   ./scriptName.sh
   ```

    Note that each script requires certain variables to be set before it can run properly. These variables are detailed in the README under each script heading. Some actions, like apprise or docker, have prerequisites, but they should be fairly obvious. The suite of scripts is designed to run in a [Saltbox](https://github.com/saltyorg/Saltbox) server environment but might work on other Debian-based Linux operating systems as well.

And that's it! With these steps, you can now run the maxmisc scripts on your system. If you encounter any issues during installation or setup, don't hesitate to consult the README or reach out to the project's contributors for assistance.

## The Scripts

### atrain.sh - The A-Train Installer

The `atrain.sh` script is an A-Train installer that streamlines the process of setting up [A-Train](https://github.com/m-rots/a-train) on your system. A-Train is an automation tool designed to work in conjunction with Autoscan for managing your media libraries.

If you have [Saltbox](https://github.com/saltyorg/Saltbox) installed there is no need to use this script, [saltbox now has an automated role](https://docs.saltbox.dev/sandbox/apps/a_train/).

Follow these steps to run **`atrain.sh`**:

1. **Check the script configuration:**
    Before running the script, make sure that the required variables are properly set in the `maxmisc.conf file`. The essential variables for this script are:

   - atrainname: The name of the A-Train container.
   - appdir: The directory where the application will be installed.
   - network: The network used by the container.

2. **Execute the script:**
    Run the script using the following command:

   ```sh
   ./atrain.sh
   ```

    This will execute a series of functions to install and configure A-Train:

   - Check for the existence of the A-Train directory and configuration file. If they don't exist, create them.
   - Pull the latest A-Train Docker image.
   - Run the Docker container with the specified settings.
   - Stop the A-Train Docker container for configuration.
   - Display relevant documentation and configuration instructions.

3. **Configure A-Train:**
    After running the script, you will be provided with instructions and the location of the configuration file. The configuration file, a-train.toml, can be found in the following directory:

   ```sh
   ${appdir}/a-train.toml
   ```

    Edit this file to set your Autoscan URL, username, password, service account key file, and shared drive IDs as required.

4. **Start A-Train:**
    Once the configuration is complete, start the A-Train Docker container with the following command:

   ```sh
   docker start ${atrainname}
   ```

Congratulations! You have successfully installed and configured A-Train using the atrain.sh script. This powerful tool is now ready to work seamlessly with Autoscan to manage your media libraries.

### backup.app.sh - Backup Your Application Data

The `backup.app.sh` script is a handy utility for backing up your application data. It stops the specified Docker container, creates a tarball archive of your application's data, uploads the archive to a remote storage drive using rclone, and restarts the Docker container.

To use `backup.app.sh`:

1. **Configure the script variables:**
   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. The essential variables for this script are:

   - `APPNAME`: The name of your app (used in the filename).
   - `PARENTDIR`: The parent directory containing the app data.
   - `APPDIR`: The app directory to be backed up.
   - `BKUPDIR`: The local backup directory.
   - `BKUPDRV`: The rclone config name of the destination shared drive (e.g., 'google').
   - `SRVR`: The name of your server (used in the filename).
   - `THEDOCKER`: The name of your app's Docker container.

2. **Execute the script:**
   Run the script using the following command:

   ```sh
   ./backup.app.sh
   ```

   This command will stop the specified Docker container, create a tarball archive of your application's data, upload the archive to a remote storage drive using rclone, and restart the Docker container.

With the `backup.app.sh` script, you can easily create backups of your application data and ensure the safety of your valuable information.

### cropduster.sh - Install and Set Up Crop

The `cropduster.sh` script automates the installation and setup of Crop, a powerful utility for managing files on cloud storage. Crop is developed by l3uddz and can be found on GitHub [here](https://github.com/l3uddz/crop).

Here's how to use the `cropduster.sh` script:

1. **Configure the script variables:**
   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. The essential variables for this script are:

   - `cropname`: The name of the Crop directory (default: "crop").
   - `appdir`: The parent directory for installing Crop (default: "/opt").

2. **Execute the script:**
   Run the script using the following command:

   ```sh
   ./cropduster.sh
   ```

   This command will create the Crop directory, download the latest Crop release, lclone, and a sample configuration file. It will also set the necessary permissions for the downloaded files.

3. **Configure Crop:**
   After running the script, navigate to the Crop directory:

   ```sh
   cd /opt/crop
   ```

   Copy the sample configuration file to create your own configuration:

   ```sh
    cp config.yaml.sample config.yaml`
   ```

   Open `config.yaml` using your favorite text editor (e.g., nano, vim) and edit the configuration according to your needs.

4. **Access Crop documentation:**
   For detailed information on using Crop, refer to the [official GitHub repository](https://github.com/l3uddz/crop).

By following these steps, you will have successfully installed and set up Crop using the `cropduster.sh` script.

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

An plex cleaner. WIP, **not safe to use**.

### plex_futures_n_stuckers.sh

Plex futures and plex stuckers in the same script.

### plex_futures.sh - Update future-dated Plex Items

The `plex_futures.sh` script corrects Plex items that have an incorrect added date in the future. By updating the `added_at` field for these items to the current date and time, this script ensures that your Plex library displays accurate information.

Here's how to use the `plex_futures.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. The essential variables for this script are:

   - `plexdockername`: The name of the Plex Docker container (default: "plex").
   - `plexdbpath`: The path to the Plex database directory (default: "/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/").
   - `plexdb`: The name of the Plex database file (default: "com.plexapp.plugins.library.db").
   - `plexsql`: The path to the SQLite executable used by Plex (default: "/opt/plexsql/Plex Media Server").

2. **Execute the script:**

   Run the script using the following command:

   ```sh
   ./plex_futures.sh
   ```

   This command will stop the Plex Docker container, navigate to the Plex database directory, create a backup of the Plex database, remove temporary files if they exist, and update the `added_at` field for future-dated items. Finally, the script will restart the Plex Docker container.

By following these steps, you will have successfully corrected future-dated items in your Plex library using the `plex_futures.sh` script.

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
