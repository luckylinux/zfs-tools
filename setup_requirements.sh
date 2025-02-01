#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Pool Name
poolname=${1:-"zdata"}

# Load Configuration and Functions
source "${toolpath}/load.sh"

# Get Distribution OS Release
distribution=$(get_os_release)

# Configure Backport Packages
if [[ "${distribution}" == "debian" ]]
then
   # Use Smartctl from Backports
   tee /etc/apt/preferences.d/smarmontools <<- EOF
	Package: smartmontools
	Pin: release n=bookworm-backports
	Pin-Priority: 900
EOF
fi

# Install Requirements
if [ "${distribution}" == "debian" ] || [ "${distribution}" == "ubuntu" ]
then
   # Install Packages
   apt-get install --yes inotify-tools
elif [ "${distribution}" == "fedora" ]
then
   # Install Packages
   dummyvar=0
fi
