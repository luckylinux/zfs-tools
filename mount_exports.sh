#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source "${toolpath}/load.sh"

# For each folder
mount -a

# Restart nfs if Installed
if systemctl list-unit-files nfs-kernel-server.service &>/dev/null; then systemctl restart nfs-kernel-server; fi
