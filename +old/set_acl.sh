#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load configuration
source ${toolpath}/load.sh

# Ask for user
read -p "Username to grant permissions to: " username

# Ask for folder
read -p "Folder to grant permissions to: " foldername

# Change folder to $foldername
cd $foldername

# Set ACLs for main directory
# Set FACLs for $username
setfacl -m u:$username:rwx $foldername
setfacl -d -m u:$username:rwx $foldername

# Set FACLs for administrator
setfacl -m u:administrator:rwx $foldername
setfacl -d -m u:administrator:rwx $foldername

# For each drirectory in there
for directory in *;
do
	if [ -d "$foldername/$directory/" ]
	then
		# Print message
		echo "Setting ACLs for $foldername/$directory (users: $username , administrator)"

		# Set FACLs for $username
		setfacl -Rm u:$username:rwx $foldername/$directory
		setfacl -d -Rm u:$username:rwx $foldername/$directory

		# Set FACLs for administrator
		setfacl -Rm u:administrator:rwx $foldername/$directory
		setfacl -d -Rm u:administrator:rwx $foldername/$directory

		# Do this also for subdirectories
		for subdirectory in $directory/*;
		do
			if [ -d "$foldername/$directory/$subdirectory/" ]
			then
				# Print message
				echo "Setting ACLs for $foldername/$directory/$subdirectory (users: $username , administrator)"

				# Set FACLs for $username
				setfacl -Rm u:$username:rwx $foldername/$directory/$subdirectory/
				setfacl -d -Rm u:$username:rwx $foldername/$directory/$subdirectory/

				# Set FACLs for administrator
				setfacl -Rm u:administrator:rwx $foldername/$directory/$subdirectory/
				setfacl -d -Rm u:administrator:rwx $foldername/$directory/$subdirectory/
			fi
		done
	fi
done
