#!/bin/zsh
# This script syncs an Android with a Mac using adb and adb-sync.
# Version 12.1 (09 June 2021)
# Added excluding .DS_Store. Unfortunately can only exclude one file

# Export paths for use if the script is turned into an app using Platypus.
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/$"

# Sets the local paths
export LOG=~/Library/Logs/mobisync.log
export DOWNLOADS=~/Downloads/

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
{ echo "mobisync 12.1"; echo "Log: " `date`; line; } >> $LOG

# Syncing images and video on device to the Downloads folder on computer.
{ 
    adb shell find "/sdcard/DCIM/" -type f -iname \*.jpg -o -type f -iname \*.mp4 -o -type f -iname \*.dng | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; 
    adb shell find "/sdcard/Pictures/" -type f -iname \*.jpg -o -type f -iname \*.mp4 -o -type f -iname \*.dng | tr -d '\015' | while read line; do adb pull "$line" $DOWNLOADS; done; 
} >> $LOG
catcher Images
line

# Syncing documents on device to the Downloads folder on computer.
{ 
    adb-sync --reverse --times "/sdcard/Documents/Checkin/" ~/Documents/Checkin/; 
    adb-sync --reverse --times --delete "/sdcard/Documents/Logistics/" ~/Documents/Logistics/; 
    adb-sync --exclude .DS_Store --delete ~/Documents/Papers.sparsebundle/ "/sdcard/Documents/Papers.sparsebundle/"; 
    adb-sync --reverse "/sdcard/Download/" $DOWNLOADS; 
} >> $LOG
catcher Documents
line

# Syncing Automate data on device to the computer.
{ 
    adb-sync --two-way --exclude .DS_Store ~/Projects/Programming/push/automate/ "/sdcard/.automate/Interface/"; 
    adb-sync --reverse "/sdcard/.automate/" ~/Mobile/Automate/; 
} >> $LOG
catcher Automate
line

# Syncing app, recovery and backups.
{ 
    adb-sync --reverse "/sdcard/Restore/" ~/Mobile/Restore/; 
    adb-sync --reverse --times "/sdcard/Backup/" ~/Mobile/Backup/; 
} >> $LOG
catcher Backup
line

# Syncing Music from the computer.
{ 
    adb-sync --delete --exclude .DS_Store  ~/Music/ "/sdcard/Music/"; 
} >> $LOG
catcher Music
line

# Notification that the sync is over.
printf "Syncing is complete. END" >> $LOG
line
verify $ERROR

echo "QUITAPP"