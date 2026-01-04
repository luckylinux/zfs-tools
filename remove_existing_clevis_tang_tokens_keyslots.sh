#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source "${toolpath}/load.sh"

# Ask for password
read -s -p "Enter encryption password: " password

# For each Device
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Get Device Path
    device_path=$(get_device_reference "${disk_config}")

    # Existing CLEVIS Tang Slots
    mapfile existing_clevis_tang_keyslots < <(clevis luks list -d "${device_path}" | grep -E "[0-9]+: tang" | sed -E "s|([0-9]+): tang.*|\1|g")

    # Initialize Counter
    counter=1

    # For each keyserver found
    for existing_clevis_tang_keyslot in "${existing_clevis_tang_keyslots[@]}"
    do
        # Unbind device from the TANG server via CLEVIS
        echo "Remove Keyserver <${keyserver}> from $device LUKS Header"
        echo $password | clevis luks unbind -d "${device_path}" -s ${existing_clevis_tang_keyslot}

        # Increment counter
        counter=$((counter+1))
     done
done

# Clear password from memory
unset $password

# Update initramfs
# update-initramfs -k all -u

# Get information
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Get Keyslots Information
    cryptsetup luksDump "${device_path}"
    clevis luks list -d "${device_path}"
done
