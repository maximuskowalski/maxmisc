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

### Plex_stuckers.sh - Reset Plex `added_at` Dates to Airdate or Premiere Date

The `plex_stuckers.sh` script resets the `added_at` dates of Plex items to their airdate or premiere date, ensuring that your Plex library displays accurate and consistent information.

Here's how to use the `plex_stuckers.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. The essential variables for this script are:

   - `plexdockername`: The name of the Plex Docker container (default: "plex").
   - `plexdbpath`: The path to the Plex database directory (default: "/opt/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/").
   - `plexdb`: The name of the Plex database file (default: "com.plexapp.plugins.library.db").
   - `plexsql`: The path to the SQLite executable used by Plex (default: "/opt/plexsql/Plex Media Server").

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./plex_stuckers.sh`
   ```

   This command will stop the Plex Docker container, navigate to the Plex database directory, create a backup of the Plex database, remove temporary files if they exist, and update the `added_at` field to match the `originally_available_at` field for items with mismatched dates. Finally, the script will restart the Plex Docker container.

By following these steps, you will have successfully reset the `added_at` dates of Plex items to their airdate or premiere date using the `plex_stuckers.sh` script.

### plex_transfer.sh - Transfer Plex Database and Metadata to Another Instance

The `plex_transfer.sh` script allows you to transfer a Plex database and its associated metadata to another Plex instance. This is useful when you need to migrate your Plex library between servers or set up a new instance with the same content.

Here's how to use the `plex_transfer.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. The essential variables for this script are:

   - `backupdrive`: The rclone config name of the backup share drive (e.g., 'google').
   - `plexdockername`: The name of the Plex Docker container (default: "plex").
   - `plexservername`: The name of your Plex server (used in the filename).
   - `thisserver`: The name of your current server (e.g., "hetzner01").
   - `bkupdir`: The local backup directory (default: "/home/USER/appbackups").
   - `plexdblocation`: The absolute path to the Plex database file.
   - `plexmdlocation`: The absolute path to the Plex metadata directory.
   - `plextrnsfrdb`: The file path for the temporary transfer backup of the Plex database.

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./plex_transfer.sh
   ```

   This command will create the backup directory if it doesn't already exist, stop the Plex Docker container, create a temporary transfer backup of the Plex database, restart the Plex Docker container, compress the Plex metadata and temporary transfer backup into a `.tar.gz` archive, and upload the archive to the specified backup drive using rclone.

After the script has completed, you will see a message confirming the backup file's creation and its location. You can then transfer this backup file to the target server or instance, where you can restore the Plex database and metadata using `plex_unpack.sh`, or some other suitable script or method.

### plex_unpack.sh - Restore Plex Database and Metadata on Receiving Instance

The `plex_unpack.sh` script is used on the receiving end when you transfer a Plex database and its associated metadata to another instance. This script restores the transferred Plex database and metadata on the target instance.

Here's how to use the `plex_unpack.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. The essential variables for this script are:

   - `backupdrive`: The rclone config name of the backup share drive (e.g., 'google').
   - `plexdockername`: The name of the Plex Docker container (default: "plex").
   - `plexbuservername`: The name of the Plex server from which the backup was taken (used in the filename).
   - `bufromserver`: The name of the server from which the backup was taken (e.g., "hetzner01").
   - `bkupdir`: The local backup directory (default: "/home/USER/appbackups").
   - `plexdblocation`: The absolute path to the Plex database file on the target instance.
   - `plextrnsfrdb`: The file path for the temporary transfer backup of the Plex database on the target instance.

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./plex_unpack.sh
   ```

   This command will create the backup directory if it doesn't already exist, stop the Plex Docker container, download the backup archive from the specified backup drive using rclone, extract the Plex metadata and temporary transfer backup from the archive, copy the temporary transfer backup to the target Plex database location, and start the Plex Docker container.

After the script has completed, the Plex database and metadata from the donor instance will be restored on the target instance.

### quack.sh - A Quick Incremental Backup Script for Config Files and Scripts

The `quack.sh` script is a quick incremental backup tool for configuration files and scripts from your Saltbox installations. It is not a complete Saltbox backup solution. The script takes care of backing up user crontab, system information, and specific directories mentioned in the configuration files.

Here's how to use the `quack.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. Some essential variables for this script are:

   - `myusername`: Your username.
   - `qkupdir`: The root directory for the backup.
   - `fileslist`, `filtlist`, `ziplist`: Paths to the files containing the list of files, directories, and zip directories, respectively.
   - `qakupload`: Boolean variable indicating if the backup should be uploaded.
   - `backupdrive`: The rclone config name of the backup share drive (e.g., 'maxbackup').
   - `thisserver`: The name of the server being backed up.

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./quack.sh
   ```

   This command will perform a sequence of tasks, including checking for root runners, creating destination directories, copying specified files and directories, zipping certain directories, rotating backups, and uploading the backup if configured to do so. The script will display a "backup complete" message when it's done.

After the script has completed, your specified configuration files and scripts will be backed up in the backup directory specified in the script.

### restore.app.sh - A Script to Restore an App Backed Up Using backup.app.sh

`restore.app.sh` is a script used to restore an app that has been backed up using the `backup.app.sh` script. It retrieves the backup file from a remote location and restores the app data in the specified directory.

Here's how to use the `restore.app.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. Some essential variables for this script are:

   - `PARENTDIR`: The parent directory in which the backup directory is nested (e.g., docker appdata).
   - `APPDIR`: The app directory to restore.
   - `RESTOREDIR`: The local directory to save the tar file for restore.
   - `BKUPDRV`: The rclone config name of the backup share drive (e.g., 'maxbackup').
   - `FILEPATH`: The path on the rclone remote to the file.
   - `FILENAME`: The name of the file to restore.
   - `THEDOCKER`: The name of your app docker - to stop and start.

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./restore.app.sh
   ```

   This command will perform a sequence of tasks, including checking for the necessary directories, pulling the backup file from the remote storage, stopping the Docker container if it exists, extracting the backup file, and starting the Docker container.

After the script has completed, your specified app will be restored from the backup file in the target directory.

### sarotund.sh - A Script to Install SARotate

`sarotund.sh` is a script that installs [SARotate](https://github.com/saltydk/SARotate), an application that rotates mount points for rclone remotes to prevent API bans.

Here's how to use the `sarotund.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. Some essential variables for this script are:

   - `sarotatename`: The name of the SARotate directory (default: sarotate).
   - `appdir`: The parent directory where SARotate will be installed.
   - `sarsysdinst`: Set to `true` if you want to create a systemd file and enable it. The service will not start automatically.

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./sarotund.sh
   ```

   This command will perform a sequence of tasks, including checking for the necessary directories, downloading SARotate, creating a sample configuration file, and optionally creating and enabling a systemd service.

After the script has completed, SARotate will be installed in the specified directory. Make sure to create or edit the `config.yaml` file based on the provided `config.yaml.sample` before attempting to start SARotate.

### sarotup.sh - A Script to Update SARotate

`sarotup.sh` is a script that updates [SARotate](https://github.com/saltydk/SARotate), an application that rotates mount points for rclone remotes to prevent API bans.

Here's how to use the `sarotup.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. Some essential variables for this script are:

   - `sarotatename`: The name of the SARotate directory (default: sarotate).
   - `appdir`: The parent directory where SARotate is installed.

2. **Execute the script:**

   Run the script using the following command:

   ```shell
   ./sarotup.sh
   ```

   This command will perform a sequence of tasks, including checking for the existing SARotate executable, downloading the latest version, and updating the executable.

   During the update process, the script will prompt you if your new config file is ready. Make sure to create or edit the `config.yaml` file based on the provided `config.yaml.sample` before attempting to start SARotate.

After the script has completed, SARotate will be updated to the latest version.

### strapon.sh

Bootstrap an ubuntu server with my common enough tasks that I have a script ready to go. Kind of specific. WIP, **not safe to use**.

### wanchors.sh - A Script to Watch Anchor Files and Prevent Docker Apps from Running

`wanchors.sh` is a script that watches specified anchor files and stops specified Docker apps (e.g., Plex, Emby, Jellyfin) if any of the anchor files are missing. This prevents the libraries from being emptied when the rclone mounts are not working correctly. You can run the script at a desired interval using cron.

Here's how to use the `wanchors.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. Some essential variables for this script are:

   - `ANCHOR`: The anchor files you want to watch, separated by commas (e.g., `td_tv1.bin,td_movies.bin`).
   - `DIR`: The location of the anchor files (e.g., `/mnt/unionfs`).
   - `SAPPS`: The Docker service apps you want to stop if the anchor files are missing, separated by spaces (e.g., `plex emby jellyfin`).
   - `NOTIFICATION`: A placeholder variable for an optional notification script.

2. **Add the script to the cron:**

   Open the crontab editor with the following command:

   ```shell
   crontab -e
   ```

   Add the following line to your crontab file to run the script every minute:

   ```shell
   * * * * /path/to/wanchors.sh`
   ```

   Replace `/path/to/wanchors.sh` with the actual path to the script.

   Save and exit the editor.

The script will now run at the specified interval and stop the Docker apps if any of the anchor files are missing. This will prevent the libraries from being emptied if the rclone mounts are not working correctly.

### wanchplus.sh - A Script to Watch Anchor Files, Stop and Restart Docker Apps, and System Services

`wanchplus.sh` is a script that watches specified anchor files and stops specified Docker apps (e.g., Plex, Emby, Jellyfin) if any of the anchor files are missing. It then restarts specified system services (e.g., mergerfs) and starts the Docker apps again. This helps ensure that your library is not accidentally emptied when the rclone mounts are not working correctly. You can run the script at a desired interval using cron.

Here's how to use the `wanchplus.sh` script:

1. **Configure the script variables:**

   Before running the script, set the required variables in the script itself or in the `maxmisc.conf` file. Some essential variables for this script are:

   - `ANCHOR`: The anchor files you want to watch, separated by commas (e.g., `audiobooks,td_tv2.bin`).
   - `DIR`: The location of the anchor files (e.g., `/mnt/unionfs`).
   - `SAPPS`: The Docker service apps you want to stop and restart if the anchor files are missing, separated by spaces (e.g., `plex emby emby2 plexhex jellyfin calibre`).
   - `SYSAPPS`: The system services you want to restart, separated by spaces (e.g., `mergerfs munter`).
   - `WANCHLOG`: The log file to store the script's output (e.g., `/home/max/logs/wanch.log`).

2. **Add the script to the cron:**

   Open the crontab editor with the following command:

   ```shell
   crontab -e
   ```

   Add the following line to your crontab file to run the script every minute:

   ```shell
   * * * * /path/to/wanchplus.sh
   ```

   Replace `/path/to/wanchplus.sh` with the actual path to the script.

   Save and exit the editor.

The script will now run at the specified interval and stop the Docker apps if any of the anchor files are missing. It will then restart the specified system services and start the Docker apps again. This ensures that your library remains intact even if the rclone mounts are not working correctly.
