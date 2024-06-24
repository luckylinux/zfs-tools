#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/config.sh

# Pool name
pool=${1:-'zdata'}

# Type of unlocking
type=${2:-'password'}

# Load configuration
#source config.sh
configfile="/etc/zfs/config/$pool.sh"

# Load configuration
if [ -e "$configfile" ]; then
    source $configfile
else
    echo "File <$configfile> does NOT exist ! Aborting ..."
    exit 1
fi

# Unlock LUKS devices
# Prompt user for LUKS password
if [[ "${type}" == "password" ]]; then
   echo -n "Enter the <$pool> Pool Password: "
   read -s password
fi

# Unlock all volumes at once
for disk in "${disks[@]}"
do
    if [[ "${type}" == "password" ]]; then
        # Password Unlock
        echo -n $password | cryptsetup open "/dev/disk/by-id/${disk}-part${lukspartnumber}" "${disk}_crypt"
    else
        # Clevis Unlock
        clevis luks unlock -d "/dev/disk/by-id/${disk}-part${lukspartnumber}" -n "${disk}_crypt"
    fi
done

# Unset variable in order to enhance security
unset $password
