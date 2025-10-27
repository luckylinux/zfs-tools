#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Ask for password
read -s -p "Enter encryption password: " password
echo ""
read -s -p "Verify encryption password: " verify

if [ $password == $verify ]; then

	for disk_config in "${disks[@]}"
	do
                # Get Disk Path
                disk_name=$(get_disk_reference "${disk_config}")

                # Get Disk Partition Number
                partition_number=$(get_disk_partition_number "${disk_config}")

                # Get Device Mapper Name
                dm_name=$(get_device_mapper_name "${disk_config}")

                # Get Real Path
                disk_real_path=$(readlink --canonicalize-missing "/dev/disk/by-id/${disk_name}")

                # Get Disk Size of Current Disk
                disk_size_current=$(parted -s "${disk_real_path}" unit MiB print free 2> /dev/null | grep -E "^Disk /dev/" | head -n1 | sed -E "s|Disk ${disk_real_path}: ([0-9]+)MiB|\1|g")

                # Determine Partition End Location
                partition_end=$(($disk_size_current-$partition_start-$partition_margin))

        	# Display device informations
        	parted /dev/disk/by-id/$device print

		# Prompt user for confirmation
       		while true; do
                	read -p "Erase all partitions on /dev/disk/by-id/$device ? [y / n] " answer
                	case $answer in
                        	[Yy]* ) break;;
                       		[Nn]* ) exit;;
                        	* ) echo "Please answer yes or no.";;
                	esac
        	done

		# Create GPT label
		parted -s /dev/disk/by-id/$device mklabel GPT

		# Create one partition
      		parted --align=opt /dev/disk/by-id/$device mkpart primary "${partition_start}MiB" "${partition_end}MiB"

		# Wait for link in /dev/disk/by-id/ to "*-part1" to be created
		sleep 5

		# Encrypt disks
		# echo $password | cryptsetup -v --type luks2 --cipher aes-xts-plain64:sha512 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${disk_name}-part${partition_number}"
		echo $password | cryptsetup -q -v --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --use-random --iter-time 5000 luksFormat /dev/disk/by-id/"${disk_name}-part${partition_number}"
	done
else
	echo "Password do not match. Aborting ..."
fi

# Clear password from memory
unset $password
unset $verify
