#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Create folder
mkdir -p "${toolpath}/results/badblocks"

# Init TMUX Session
tmux new-session -d -s "testDevices" -n "General"

# Initialize Counter
counter=1

# Loop over all Devices
for disk_config in "${disks[@]}"
do
     # Get Disk Path
     disk_name=$(get_disk_reference "${disk_config}")

     # Get Disk Partition Number
     partition_number=$(get_disk_partition_number "${disk_config}")

     # Get Device Mapper Name
     dm_name=$(get_device_mapper_name "${disk_config}")

     # Create new TMUX Window
     tmux new-window -t testDevices:${counter} -n ${disk_name}

     # Select Window
     tmux select-window -t testDevices:${counter}

     # Execute Command
     tmux send-keys -t testDevices:${counter} "${toolpath}/test-disks/test_single_device.sh \"${disk_name}\"" ENTER

     # Increase counter
     counter=$(($counter+1))
done
