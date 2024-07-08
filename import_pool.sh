#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Pool Name
pool=${1:-"zdata"}

# Type of Unlocking
type=${2:-"password"}

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Unlock Encrypted Devices
source "${toolpath}/unlock_devices.sh" "${pool}" "${type}" "${configfile}"

# Import Pool
zpool import "${pool}"

# Disable automatic mounting for Backup Datasets / Snapshots
#######source "${toolpath}/disable_automatic_mounting_backup_snapshots.sh"

# Mount Datasets
source "${toolpath}/mount_datasets.sh" "${pool}"

# Mount NFS Exports
source "${toolpath}/mount_exports.sh" "${pool}"
#######zfs mount -a

# Mount all Datasets in /etc/fstab
########mount -a

# Restart NFS & Samba if they are Installed and NOT Masked
if systemd_exists_isnotmasked "smbd.service"
then
    systemctl restart smbd
fi

if systemd_exists_isnotmasked "nfs-kernel-server.service"
then
    systemctl restart nfs-kernel-server
fi

if systemd_exists_isnotmasked "nfs-common.service"
then
    systemctl restart nfs-common
fi
