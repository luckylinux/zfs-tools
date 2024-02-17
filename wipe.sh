#!/bin/bash

# If toolpath not set, set it to current working directory
if [[ ! -v toolpath ]]
then
    toolpath=$(pwd)
fi

# Load configuration
source $toolpath/config.sh

#DISABLED: Do it manually
#echo "Testing /dev/${device} using badblocks ..."
#badblocks -c 10240 -wsv /dev/$device &
	
#DISABLED: Do it manually
#echo "Shredding /dev/${device} using shred ..."
#shred -v -n 1 /dev/$device 
