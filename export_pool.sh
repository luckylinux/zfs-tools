#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

# Pool name
pool=${1:-'zdata'}

# Load configuration
#source config.sh
configfile="/etc/zfs/config/$pool.sh"

# Load configuration
if [ -e "$configfile" ]
then
    source $configfile
else
    echo "File <$configfile> does NOT exist ! Aborting ..."
    exit 1
fi

# Export pool
zpool export $pool

# Lock all volumes at once
for disk in "${disks[@]}"
do
     cryptsetup luksClose "${disk}_crypt"
done

# Unset variable in order to enhance security
unset $password
