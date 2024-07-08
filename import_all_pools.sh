#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Type of Unlocking
type=${1:-"clevis"}

# Load Functions
source "${toolpath}/functions.sh"

# Get List of Configured Pools
mapfile -t configfiles < <( find "/etc/zfs-management/pool.conf.d" -iname "*.sh" )

# Loop Over each Pool Configuration File
for configfile in "${configfiles[@]}"
do
    # Load Configuration File in Order to Load <pool> Parameter
    source "${configfile}"

    # Alternative Approach: get <pool> Parameter from Filename
    #pool=$(echo basename "${configfile}" | sed -E "s|^([0-9a-zA-Z]*?)\.sh|\1|"

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
done

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
