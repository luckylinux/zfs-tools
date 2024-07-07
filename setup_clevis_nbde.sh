#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Pool Name
pool=${1:-"zdata"}

# Load configuration
source ${toolpath}/load.sh

# Update APT Lists
apt-get update

# Install clevis on the system and add clevis to the initramfs
apt-get install --yes clevis clevis-luks clevis-initramfs cryptsetup-initramfs

# Ask for password
read -s -p "Enter encryption password: " password

# For each keyserver
keyservercounter=1
for keyserver in "${keyservers[@]}"
do
     # Get TANG Server Key
     curl -sfg http://${keyserver}/adv -o /tmp/keyserver-${keyservercounter}.jws

     # For each disk device
     for device in "${devices[@]}"

	# Check which keys are currently used via CLEVIS
	list_device_keys=$(clevis luks list -d ${device}-part1)

     	# Bind device to the TANG server via CLEVIS
	if [[ "${list_device_keys}" == *"${keyserver}"* ]]; then
        	echo "Keyserver <${keyserver}> is already installed onto <${device}> LUKS Header"
     	else
        	echo "Install Keyserver <${keyserver}> onto <${device}> LUKS Header"
        	echo ${password} | clevis luks bind -d ${device}-part1 tang "{\"url\": \"http://${keyserver}\" , \"adv\": \"/tmp/keyserver-${keyservercounter}.jws\" }"
     	fi

	# Get information about LUKS and Clevis Keyslots
	cryptsetup luksDump ${device}-part1
	clevis luks list -d ${device}-part1
     done

     # Increment counter
     keyservercounter=$((keyservercounter+1))
done

# Clear password from memory
unset $password

# Update initramfs
update-initramfs -c -k all

