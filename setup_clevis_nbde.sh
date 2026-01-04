#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Pool Name
pool=${1:-"zdata"}

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Only Process the specific Disks, if the User chooses to
if [ "$#" -gt 1 ]
then
    # Unset existing Variable
    disks=()

    # Disks
    disks=${@:2}
fi

# Debug
echo "Pool set to: $pool"
echo "Disks to be setup for use with Clevis:"
for d in ${disks[@]}
do
    echo -e "\t- ${d}"
done

# Get Distribution OS Release
distribution=$(get_os_release)

# Install Requirements
if [ "${distribution}" == "debian" ] || [ "${distribution}" == "ubuntu" ]
then
   # Update APT Lists
   apt-get update

   # Install Clevis on the System and add Clevis to the Initramfs
   apt-get install --yes clevis clevis-luks clevis-initramfs cryptsetup-initramfs
elif [[ "${}" == "fedora" ]]
then
   # Update DNF Lists
   dnf update

   # Install Clevis on the System and add Clevis to the Initramfs
   dnf -y clevis clevis-luks clevis-dracut
fi

# Ask for password
read -s -p "Enter encryption password: " password

# For each keyserver
#keyservercounter=1
#for keyserver in "${keyservers[@]}"
#do
#     # Get TANG Server Key
#     curl -sfg http://${keyserver}/adv -o /tmp/keyserver-${keyservercounter}.jws
#
#     # For each disk device
#     for disk_config in "${disks[@]}"
#     do
#         # Get Disk Path
#         disk_name=$(get_disk_reference "${disk_config}")
#
#         # Get Disk Partition Number
#         partition_number=$(get_disk_partition_number "${disk_config}")
#
#         # Get Device Mapper Name
#         dm_name=$(get_device_mapper_name "${disk_config}")
#
#         # Get Device Path
#         device_path=$(get_device_reference "${disk_name}" ${partition_number})
#
#	  # Echo
#	  echo "Processing Device /dev/disk/by-id/${disk_name}"
#
#	  # Check which keys are currently used via CLEVIS
#	  list_device_keys=$(clevis luks list -d "${device_path}")
#
#         # Bind device to the TANG server via CLEVIS
#	  if [[ "${list_device_keys}" == *"${keyserver}"* ]]
#         then
#        	echo "Keyserver <${keyserver}> is already installed onto ${device_path} LUKS Header"
#     	  else
#         	echo "Install Keyserver <${keyserver}> onto ${device_path} LUKS Header"
#        	echo "${password}" | clevis luks bind -d ${device_path} tang "{\"url\": \"http://${keyserver}\" , \"adv\": \"/tmp/keyserver-${keyservercounter}.jws\" }"
#	  fi
#
#	  # Get information about LUKS and Clevis Keyslots
#	  cryptsetup luksDump "${device_path}"
#	  clevis luks list -d "${device_path}"
#     done
#
#     # Increment counter
#     keyservercounter=$((keyservercounter+1))
#done

# Use pre-build Dictionary
for disk_config in "${disks[@]}"
do
    # Get Disk Path
    disk_name=$(get_disk_reference "${disk_config}")

    # Get Disk Partition Number
    partition_number=$(get_disk_partition_number "${disk_config}")

    # Get Device Mapper Name
    dm_name=$(get_device_mapper_name "${disk_config}")

    # Get Device Path
    device_path=$(get_device_reference "${disk_name}" ${partition_number})

    echo "Install Keyservers onto ${device_path} LUKS Header"
    echo ${tangkeyserverdict} | jq -r --color-output
    echo $password | clevis luks bind -d "${device_path}" -s ${clevis_luks_keyslot} -f sss "${tangkeyserverdict}"
done

# Clear password from memory
unset $password

# Rebuild initramfs
if [ "${distribution}" == "debian" ] || [ "${distribution}" == "ubuntu" ]
then
    update-initramfs -k all -u
elif [ "${distribution}" == "fedora" ]
then
    dracut --regenerate-all --force
fi
