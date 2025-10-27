#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Disk Name to be encrypted
disk_name=${1:-""}

# Ask interactively if not specified
if [[ -z "${disk_name}" ]]
then
    read -p "Enter the Disk Name to be erased/(re)initialized (e.g. ata-XXXXXXXXXXXXXX): " disk_name
fi

# Display device informations
parted /dev/disk/by-id/${disk_name} print

# Prompt user for confirmation
while true; do
      read -p "Erase all Partitions on /dev/disk/by-id/${disk_name} and (re)initialize Drive ? [y / n] " answer
      case $answer in
           [Yy]* ) break;;
           [Nn]* ) exit;;
               * ) echo "Please answer yes or no.";;
      esac
done

# Create GPT label
parted -s /dev/disk/by-id/${disk_name} mklabel GPT
