#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Pool name
pool=${1:-"zdata"}

# Load Configuration and Functions
source "${toolpath}/load.sh"

# For each folder
mount -a

# Restart nfs if Installed and NOT Masked
if systemd_exists_isnotmasked "nfs-kernel-server.service"
then
   systemctl restart nfs-kernel-server
fi
