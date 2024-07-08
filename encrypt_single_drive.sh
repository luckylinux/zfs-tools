#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Device to be encrypted
device=${1:-""}

# Ask interactively if not specified
if [[ -z "${device}" ]]
then
    read -p "Enter the Device ID to be encrypted (e.g. ata-XXXXXXXXXXXXXX): " device
fi

# Display device informations
parted /dev/disk/by-id/${device} print

# Prompt user for confirmation
while true; do
      read -p "Erase all partitions on /dev/disk/by-id/${device} ? [y / n] " answer
      case $answer in
           [Yy]* ) break;;
           [Nn]* ) exit;;
               * ) echo "Please answer yes or no.";;
      esac
done

# Create GPT label
parted -s /dev/disk/by-id/${device} mklabel GPT

# Create one partition
parted --align=opt /dev/disk/by-id/${device} mkpart primary "${partition_start}MiB" "${partition_end}MiB"

# Wait for link in /dev/disk/by-id/ to "*-part1" to be created
sleep 5

# Encrypt disks
#cryptsetup -v --cipher aes-xts-plain64:sha512 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${device}-part1"
cryptsetup -q -v --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${device}-part1"
