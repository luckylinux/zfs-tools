#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Pool name
pool=${1:-'zdata'}

# Type of unlocking
type=${2:-'password'}

# Load configuration
source ${toolpath}/load.sh

# Unlock Encrypted Devices
source unlock_devices.sh "${pool}" "${type}" "${configfile}"

# Import pool
zpool import $pool

# Disable automatic mounting for backup datasets
bash disable_automatic_mounting_backup_snapshots.sh

# Import all datasets
bash import_datasets.sh

# Mount datasets
bash mount_exports.sh
#######zfs mount -a

# Mount all datasets in /etc/fstab
########mount -a

# Restart NFS & samba
/etc/init.d/smbd restart
/etc/init.d/nfs-kernel-server
/etc/init.d/nfs-common restart
