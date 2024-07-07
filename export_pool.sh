#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Pool name
pool=${1:-'zdata'}

# Load configuration
source ${toolpath}/load.sh

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
