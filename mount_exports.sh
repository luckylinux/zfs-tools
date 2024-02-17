#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

# For each folder
mount -a

# Restart nfs
/etc/init.d/nfs-kernel-server restart
