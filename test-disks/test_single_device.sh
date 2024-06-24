#!/bin/bash

# Determine toolpath if not set already
relativepath="../" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Get device as argument
device=${1-""}

if [[ -z "${device}" ]]
then
    read -p "Enter Device to be tested: " device
fi

# Create folder
mkdir -p "${toolpath}/results/badblocks"

# Run SMART Test
# Stop if there is a test already running
smartctl -X /dev/disk/by-id/$device

# Wait for operation to terminate
sleep 5

# Run self-test
smartctl --test=long /dev/disk/by-id/$device

# Generate Timestamp
timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

# Wait 12h for the Test to complete
sleep 43200

# Analyse SMART Results
# Show all test results
smartctl --attributes --log=selftest /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_all.log

# Show found errors
smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_errors.log

# Run Badblocks
# Display device informations
parted /dev/disk/by-id/$device print

# Prompt user for confirmation
while true; do
        read -p "Run DESTRUCTIVE Badblocks on /dev/disk/by-id/$device ? [y / n] " answer
        case $answer in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                    * ) echo "Please answer yes or no.";;
        esac
done

# Stop if there is a test already running
smartctl -X /dev/disk/by-id/$device

# Wait for operation to terminate
#sleep 5

# Run self-test
#smartctl --test=long /dev/disk/by-id/$device

# Show found errors
#smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/$device

# Check for bad blocks
#badblocks -wsv /dev/disk/by-id/$device -o "badblocks/${device}.log" & # With progress bar
#badblocks -wv /dev/disk/by-id/$device -o "badblocks/${device}.log" & # Without progress bar
#badblocks -b 4096 -wv /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar
#badblocks -b 512 -c 65536 -wv /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar

# Do not use a progress bar
badblocks -t random -b 4096 -c 65536 -wv -s /dev/disk/by-id/$device > "${toolpath}/results/badblocks/${device}_${timestamp}.log" &

# Run another SMART Test
# Stop if there is a test already running
smartctl -X /dev/disk/by-id/$device

# Wait for operation to terminate
sleep 5

# Run self-test
smartctl --test=long /dev/disk/by-id/$device

# Generate Timestamp
timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

# Wait 12h for the Test to complete
sleep 43200

# Analyse SMART Results
# Show all test results
smartctl --attributes --log=selftest /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_all.log

# Show found errors
smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_errors.log
