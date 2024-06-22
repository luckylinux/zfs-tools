#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load config
source ${toolpath}/config.sh

# Generate date timestamp
timestamp=$(date +%Y%m%d-%H-%M)

# Create subfolders
mkdir -p "/$backupfolder/GPT/$timestamp"
mkdir -p "/$backupfolder/LUKS/$timestamp"

# Backup all partition tables
for device in "${disks[@]}"
do
	sgdisk --backup="$backupfolder/GPT/$timestamp/$device.sgdisk" "/dev/disk/by-id/$device"

done

# Backup all LUKS headers
for device in "${luksdevices[@]}"
do
	cryptsetup luksHeaderBackup "/dev/mapper/$device" --header-backup-file "$backupfolder/LUKS/$timestamp/$device.luks"
done
