#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/config.sh

# Create folder
mkdir -p "${toolpath}/results/badblocks"

# Init TMUX Session
tmux new-session -d -s "testDevices" -n "General"

# Initialize Counter
counter=1

# Loop over all Devices
for device in "${disks[@]}"
do
     # Create new TMUX Window
     tmux new-window -t testDevices:${counter} -n ${device}

     # Select Window
     tmux select-window -t testDevices:${counter}

     # Execute Command
     tmux send-keys -t testDevices:${counter} "${toolpath}/test-disk/test_single_device.sh \"aaaaaa\""

     # Increase counter
     counter=$(($counter+1))
done
