#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Abort on Error
set -e

# Tool to use to Transfer ZFS Snapshots
synctool=${1:-"syncoid"}

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

    # Load Pool Configuration and Functions
    source "${toolpath}/load.sh"

    # Load Sync Default Configuration
    if [[ -f "/etc/zfs-management/sync.conf.d/default.sh" ]]
    then
        source "/etc/zfs-management/sync.conf.d/default.sh"
    else
        echo "ERROR: /etc/zfs-management/sync.conf.d/default.sh does NOT Exist ! Aborting !!!"
        exit 9
    fi

    # Load Sync Pool-Specific Configuration (Overrides Default Configuration)
    if [[ -f "/etc/zfs-management/sync.conf.d/${pool}.sh" ]]
    then
        source "/etc/zfs-management/sync.conf.d/${pool}.sh"
    else
        echo "WARNING: /etc/zfs-management/sync.conf.d/${pool}.sh does NOT Exist ! Using Default Values from /etc/zfs-management/sync.conf.d/default.sh."
    fi

    # Sync Snapshots to Remote Server
    syncoid --recursive --compress=lz4 --no-sync-snap --create-bookmark "${pool}" "${SYNCOID_REMOTE_USER}@${SYNCOID_BACKUP_HOST}:${SYNCOID_TARGET_BACKUP_PATH}"
done
