#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load files in config-pre/ Folder
mapfile -t files < <( find "${toolpath}/config-pre/" -iname "*.sh" )

# Define Configuration
if [ -n "${pool}" ] && [ -d "/etc/zfs-management/" ] && [ -d "/etc/zfs-management/pool.conf.d" ] && [ -f "/etc/zfs-management/pool.conf.d/${pool}.sh" ]
then
    # Use "Production" Configuration File from "/etc/zfs-management/pool.conf.d/${pool}.sh"
    configfile="/etc/zfs-management/pool.conf.d/${pool}.sh"
else
    # Use "Testing" Configuration File from "${toolpath}/config.sh"
    configfile="${toolpath}/config.sh"
fi

# Process files in config-pre/ Folder
for file in "${files[@]}"
do
    source "${file}"
done

# Check if Configuration File Exists
if [[ -f "${configfile}" ]]
then
    # Echo
    echo "Load Configuration from ${configfile}"

    # Load Configuration
    source "${configfile}"
else
    echo "ERROR: file ${configfile} does NOT exist. Aborting !"
    exit 9
fi

# Load files in config-post/ Folder
mapfile -t files < <( find "${toolpath}/config-post/" -iname "*.sh" )

# Process files in config-post/ Folder
for file in "${files[@]}"
do
    source "${file}"
done

# Load functions
source "${toolpath}/functions.sh"
