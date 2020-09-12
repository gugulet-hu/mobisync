#!/bin/zsh
# This script syncs an Android with a Mac using adb and adb-sync.
# Version 11.2.1 (23 April 2020)
# Fixed System backup and Pictures folder download.

# Export paths for use if the script is turned into an app using Platypus.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/$"

# Sets the local paths
export LOG=~/Projects/Programming/push/mobisync/mobisync-log.txt
export DOWNLOADS=~/Downloads/
export MOBILE=~/Mobile/
export SIGNAL=~/Mobile/Signal/
export TENTACLES=~/Documents/.tentacles/
export MUSIC=~/Music/
export SYSTEM=/Volumes/Archive\ 01/System/
export TRAVEL=~/Documents/Travel/

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
        open $LOG
        echo "NOTIFICATION: Syncing completed with some errors."
else
        echo "NOTIFICATION: Syncing is complete"
fi
}

# Function: Creates a horizontal line in the text file.
line () {
printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - >> $LOG # Prints line
}

# Writes the header for the log file: Program, Version number, Date and Line.
{ echo "mobisync 11.2.1"; echo "Log: " `date`; line; } > $LOG

# Syncing images and video on device to the Downloads folder and sync the wallpaper on computer.
{ adb shell find "/sdcard/DCIM/Camera/" -iname "*.mp4" | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; adb shell find "/sdcard/DCIM/Camera/" -iname "*.jpg" | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; adb shell find "/sdcard/DCIM/" -iname "*.jpg" | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; adb shell find "/sdcard/Pictures/" -iname "*.jpg" | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; } >> $LOG
catcher Images
line

# Syncing audio on device to the Downloads folder on computer and Music from the computer.
{ adb shell find "/sdcard/Recordings/" -iname "*.mp3" | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; adb-sync --delete $MUSIC "/sdcard/Music/" } >> $LOG
catcher Audio
line

# Syncing documents on device to the Downloads folder on computer.
{ adb-sync --reverse $DOWNLOADS "/sdcard/Documents/"; adb-sync --reverse $DOWNLOADS "/sdcard/Download/"; adb shell rm -rf '/sdcard/Documents/*'; adb-sync --delete $TRAVEL "/sdcard/Documents/"; } >> $LOG
catcher Documents
line

# Syncing qSelf data on device to the Documents/qSelf folder on computer.
{ adb-sync --reverse --delete "/sdcard/.tentacles/" $TENTACLES; } >> $LOG
catcher Tentacles
line

# Syncing app, recovery and TWRP backups.
{ adb-sync --reverse --delete "/sdcard/Mobile/" $MOBILE; adb-sync --reverse --delete "/sdcard/Signal/Backups/" $SIGNAL; adb-sync --delete $SYSTEM "/sdcard/System/"; } >> $LOG
catcher Backups
line

# Deleting all synced media from phone.
{ adb shell rm -rf '/sdcard/Recordings/*.mp3'; adb shell rm -rf '/sdcard/Movies/*'; adb shell rm -rf '/sdcard/DCIM/*'; adb shell rm -rf '/sdcard/Pictures/*'; adb shell rm -rf '/sdcard/Download/*'; adb shell rm -rf '/sdcard/Downloads/*' } >> $LOG
catcher Delete
line

# Notification that the sync is over.
printf "Syncing is complete. END" >> $LOG
verify $ERROR

echo "QUITAPP"