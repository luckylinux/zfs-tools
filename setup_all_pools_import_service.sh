#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Define Systemd Service File Name
systemdconfigdir="/etc/systemd/system"

# Copy Systemd Service Files
# All Pools Unlock & Import
servicename="zfs-auto-unlock-import-all"
servicefile="${servicename}.service"
destination="${systemdconfigdir}/${servicefile}"
cp "${toolpath}/etc/systemd/system/${servicefile}" "${destination}"

# Make it Executable
chmod +x "${destination}"

# Set the Correct Path (to the Folder where import_pool.sh is located)
replace_text "${destination}" "toolpath" "${toolpath}"

# Reload Systemd Daemon
systemctl daemon-reload

# By Default, Import all Pools configured in /etc/zfs-management/pool.conf.d/<pool>.sh
# Per-Pool Import can be Manually Configured using <zfs-auto-unlock-import-pool@.service> Instead

# Enable Service Start at Boot for the Selected Pool
systemctl enable "${servicename}"@.service

# (Re)start Service for the Selected Pool
systemctl restart "${servicename}".service
