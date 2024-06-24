#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source $toolpath/load.sh

#DISABLED: Do it manually
#echo "Testing /dev/${device} using badblocks ..."
#badblocks -c 10240 -wsv /dev/$device &

#DISABLED: Do it manually
#echo "Shredding /dev/${device} using shred ..."
#shred -v -n 1 /dev/$device 
