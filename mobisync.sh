#!/bin/zsh
# This script syncs an Android with a Mac using adb and adb-sync.
# Version 12.0 (27 March 2021)
# Moved to backup sync as main way to sync. No more file deletion from this script. Documents syncing added.

# Export paths for use if the script is turned into an app using Platypus.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/$"

# Sets the local paths
export LOG=~/Library/Logs/mobisync.log
export DOWNLOADS=~/Downloads/
export BACKUP=~/Mobile/Backup/
export AUTOMATE=~/Mobile/Automate/
export RESTORE=~/Mobile/Restore/
export MUSIC=~/Music/
export DOCUMENTS=~/Documents/

# Sets the remote paths
export REMOTE_IMAGES="/sdcard/DCIM/"
export REMOTE_PICTURES="/sdcard/Pictures/"
export REMOTE_THUMBNAILS="/sdcard/Pictures/.thumbnails/"
export REMOTE_AUDIO="/sdcard/Audio/"
export REMOTE_MUSIC="/sdcard/Music/"
export REMOTE_DOCUMENTS="/sdcard/Documents/"
export REMOTE_RESTORE="/sdcard/Restore/"
export REMOTE_BACKUP="/sdcard/Backup/"
export REMOTE_DOWNLOAD="/sdcard/Download/"
export REMOTE_AUTOMATE="/sdcard/.automate/"

# Set error variable
ERROR=0

echo "NOTIFICATION: Sync is starting..." # Send a notification (with logo)

# Function: Reviews the last command for errors. Then prints update complete to log or shows error dialog. Takes section variable.
catcher () {
if [ "$?" = "0" ]; then
    printf "$1 synced." >> $LOG # If no error, print sync complete to file.
    echo "" >> $LOG # Add a line to file.
else # If error, show a dialog stating the section where the error occured.
    echo "NOTIFICATION: '$1' sync failed."
    printf "$1 failed to sync." >> $LOG # If error, print sync failed to file.
    echo "" >> $LOG # Add a line to file.
    ERROR=1 # Sets variable for error in script to 1.
fi
}

# Function: If there has been an error in the script open the log file.
verify () {
if [ $ERROR = 1 ]; then
        { echo "Error: Mobisync encountered an error in execution"; line; } >> $LOG
        open $LOG
        echo "NOTIFICATION: Syncing completed with some errors."
else
        { echo "Success: Mobisync completed successfully"; line; } >> $LOG
        echo "NOTIFICATION: Syncing is complete"
fi
}

# Function: Creates a horizontal line in the text file.
line () {
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - >> $LOG # Prints line
}

# Writes the header for the log file: Program, Version number, Date and Line.
{ echo "mobisync 12.0"; echo "Log: " `date`; line; } >> $LOG

# Syncing images and video on device to the Downloads folder and sync the wallpaper on computer.
{ adb shell find $REMOTE_IMAGES -type f -iname \*.jpg -o -type f -iname \*.mp4 -o -type f -iname \*.dng | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; adb shell rm -rf $REMOTE_THUMBNAILS; adb shell find $REMOTE_PICTURES -type f -iname "*.jpg" | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; } >> $LOG
catcher Images
line

# Syncing audio on device to the Downloads folder on computer and Music from the computer.
{ adb shell find $REMOTE_AUDIO -type f -iname \*.mp3 -o -type f -iname \*.ogg | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; adb-sync --delete $MUSIC $REMOTE_MUSIC; } >> $LOG
catcher Audio
line

# Syncing documents on device to the Downloads folder on computer.
{ adb-sync --two-way $DOCUMENTS $REMOTE_DOCUMENTS; adb-sync --reverse $REMOTE_DOWNLOAD $DOWNLOADS; } >> $LOG
catcher Documents
line

# Syncing Automate data on device to the computer
{ adb-sync --reverse $REMOTE_AUTOMATE $AUTOMATE; } >> $LOG
catcher Tentacles
line

# Syncing app, recovery and backups.
{ adb-sync --two-way $RESTORE $REMOTE_RESTORE; adb-sync --reverse --delete --times $REMOTE_BACKUP $BACKUP; } >> $LOG
catcher Backup
line

# Notification that the sync is over.
printf "Syncing is complete. END" >> $LOG
line
verify $ERROR

echo "QUITAPP"