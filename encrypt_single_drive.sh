#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Disk Name to be encrypted
disk_name=${1:-""}

# Partition to be encrypted
partition=${2:-""}

# Ask interactively if not specified
if [[ -z "${disk_name}" ]]
then
    read -p "Enter the Device ID to be encrypted (e.g. ata-XXXXXXXXXXXXXX): " disk_name
fi

# Ask interactively if not specified
if [[ -z "${partition_number}" ]]
then
    read -p "Enter the Partition Number to be encrypted (e.g. 1) or <empty> to automatically Erase & Partition the entire Drive with a single Partition: " partition_number
fi

if [[ -z "${partition_number}" ]]
then
    # Display device informations
    parted /dev/disk/by-id/${disk_name} print

    # Prompt user for confirmation
    while true; do
          read -p "Erase all partitions on /dev/disk/by-id/${disk_name} ? [y / n] " answer
          case $answer in
               [Yy]* ) break;;
               [Nn]* ) exit;;
                   * ) echo "Please answer yes or no.";;
          esac
    done

    # Define Partition
    partition=1

    # Get Real Path
    disk_real_path=$(readlink --canonicalize-missing "/dev/disk/by-id/${disk_name}")

    # Get Disk Size of Current Disk
    disk_size_current=$(parted -s "${disk_real_path}" unit MiB print free 2> /dev/null | grep -E "^Disk /dev/" | head -n1 | sed -E "s|Disk ${disk_real_path}: ([0-9]+)MiB|\1|g")

    # Determine Partition End Location
    partition_end=$(($disk_size_current-$partition_start-$partition_margin))

    # Create GPT label
    parted -s /dev/disk/by-id/${disk_name} mklabel GPT

    # Create one partition
    parted --align=opt /dev/disk/by-id/${disk_name} mkpart primary "${partition_start}MiB" "${partition_end}MiB"

    # Wait for link in /dev/disk/by-id/ to "*-part1" to be created
    sleep 5
fi

# Encrypt disks
# cryptsetup -v --cipher aes-xts-plain64:sha512 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${disk_name}-part${partition_number}"
cryptsetup -q -v --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${disk_name}-part${partition_number}"
