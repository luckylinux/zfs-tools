#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

# Sizes
disk_size=476940                          # MiB
margin_size=100                           # MiB
partition_start=4                         # MiB
partition_end=$((disk_size-margin_size))  # MiB

# Device to be encrypted
device="ata-CTXXXXXXXXXXXXXXXXXX"

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
#cryptsetup -v --cipher aes-xts-plain64:sha512 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${device}-part1"
cryptsetup -q -v --type luks2 --cipher aes-xts-plain64 --hash sha512 --key-size 512 --use-random --iter-time 5000 --verify-passphrase luksFormat /dev/disk/by-id/"${device}-part1"
