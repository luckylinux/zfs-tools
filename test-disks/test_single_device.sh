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
mkdir -p "${toolpath}/results/smart"
mkdir -p "${toolpath}/pid/badblocks"

# Display device informations
parted /dev/disk/by-id/$device print

# Prompt User for Confirmation before Starting
while true; do
        read -p "Run DESTRUCTIVE Test on /dev/disk/by-id/$device ? [y / n] " answer
        case $answer in
                [Yy]* ) break;;
                [Nn]* ) exit;;
                    * ) echo "Please answer yes or no.";;
        esac
done

# Run SMART Test
# Stop if there is a test already running
smartctl -X /dev/disk/by-id/$device

# Wait for operation to terminate
sleep 5

# Run short self-test
smartctl --test=short /dev/disk/by-id/$device

# Generate Timestamp
timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

# Wait 5min for the Test to complete
sleep 300

# Analyse SMART Results
# Show all test results
smartctl --attributes --log=selftest /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_all.log

# Show found errors
smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_errors.log

# Run Badblocks

# Stop if there is a test already running
smartctl -X /dev/disk/by-id/$device

# Wait for operation to terminate
sleep 5

# Check for bad blocks
#badblocks -wsv /dev/disk/by-id/$device -o "badblocks/${device}.log" & # With progress bar
#badblocks -wv /dev/disk/by-id/$device -o "badblocks/${device}.log" & # Without progress bar
#badblocks -b 4096 -wv /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar
#badblocks -b 512 -c 65536 -wv /dev/disk/by-id/$device > "badblocks/${device}.log" & # Without progress bar

# Do not use a progress bar
# Only do the Random Test (1 Pass)
badblocks -t random -b 4096 -c 65536 -wv -s /dev/disk/by-id/$device > "${toolpath}/results/badblocks/${device}_${timestamp}.log" &

# Save Backblocks PID
pid="$!"
echo "$pid" >> "${toolpath}/pid/badblocks/${device}.pid"

# Run another SMART Test
# Stop if there is a test already running
smartctl -X /dev/disk/by-id/$device

# Wait for operation to terminate
sleep 5

# Run self-test
smartctl --test=short /dev/disk/by-id/$device

# Generate Timestamp
timestamp=$(date +"%Y%m%d_%Hh%Mm%Ss")

# Wait 5min for the Test to complete
sleep 300

# Analyse SMART Results
# Show all test results
smartctl --attributes --log=selftest /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_all.log

# Show found errors
smartctl --attributes --log=selftest --quietmode=errorsonly /dev/disk/by-id/${device} > ${toolpath}/results/smart/${device}_${timestamp}_errors.log
