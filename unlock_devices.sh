#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Pool name
pool=${1:-"zdata"}

# Type of unlocking
type=${2:-"password"}

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Wait a bit
sleep 5

# Unlock LUKS devices
# Prompt user for LUKS password
if [[ "${type}" == "password" ]]; then
   echo -n "Enter the <$pool> Pool Password: "
   read -s password
fi

# Unlock all volumes at once
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Check if Disk is already unlocked
    if [[ -e "/dev/mapper/${dm_name}" ]]
    then
        # Echo
        echo "Device /dev/disk/by-id/${disk_name}-part${partition_number} is already unlocked at /dev/mapper/${dm_name}"
    else
        # Echo
        echo "Unlocking Device /dev/disk/by-id/${disk_name}-part${partition_number}"

        # Determine how to unlock Device
        if [[ "${type}" == "password" ]]; then
            # Password Unlock
            echo -n "${password}" | cryptsetup open "/dev/disk/by-id/${disk_name}-part${partition_number}" "${dm_name}"
        else
            # Clevis Unlock
            clevis luks unlock -d "/dev/disk/by-id/${disk_name}-part${partition_number}" -n "${dm_name}"
        fi
    fi
done

# Add Basic Check to make sure the Devices have all been unlocked
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Freeze execution until /dev/mapper/${dm_name} will have been created
    inotifywait -e create --timeout 5 --include filename "/dev/mapper/${dm_name}"

    # Echo
    echo "Device /dev/disk/by-id/${disk_name}-part${partition_number} unlocked at /dev/mapper/${dm_name}. Continuing."
done

# Unset variable in order to enhance security
unset ${password}
