#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing ${scriptpath}/${relativepath}); fi

# Pool Name
pool=${1:-"zdata"}

# Load Configuration
source "${toolpath}/load.sh"

# Load functions
source "${toolpath}/functions.sh"

# Define Systemd Service File Name
systemdconfigdir="/etc/systemd/system"
servicename="zfs-auto-unlock-import-pool"
servicefile="${servicename}@.service"
destination="${systemdconfigdir}/${servicefile}"

# Copy Systemd Service File
cp "${toolpath}/etc/systemd/system/${servicefile}" "${destination}"

# Make it Executable
chmod +x "${destination}"

# Set the Correct Path (to the Folder where import_pool.sh is located)
replace_text "${destination}" "toolpath" "${toolpath}"

# Reload Systemd Daemon
systemctl daemon-reload

# Enable Service Start at Boot for the Selected Pool
systemctl enable ${servicename}@${pool}.service

# (Re)start Service for the Selected Pool
systemctl enable ${servicename}@${pool}.service
