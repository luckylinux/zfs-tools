#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Pool Name
pool=${1:-"zdata"}

# Type of Unlocking
type=${2:-"password"}

# Load Configuration
source "${toolpath}/load.sh"

# Unlock Encrypted Devices
source unlock_devices.sh "${pool}" "${type}" "${configfile}"

# Import Pool
zpool import "${pool}"

# Disable automatic mounting for Backup Datasets / Snapshots
#######source "${toolpath}/disable_automatic_mounting_backup_snapshots.sh"

# Import all Datasets
source "${toolpath}/import_datasets.sh"

# Mount Datasets
source "${toolpath}/mount_exports.sh"
#######zfs mount -a

# Mount all Datasets in /etc/fstab
########mount -a

# Restart NFS & Samba if they are Installed
if systemctl list-unit-files smbd.service &>/dev/null; then systemctl restart smbd; fi

if systemctl list-unit-files nfs-kernel-server.service &>/dev/null; then systemctl restart nfs-kernel-server; fi

if systemctl list-unit-files nfs-common.service &>/dev/null; then systemctl restart nfs-common; fi
