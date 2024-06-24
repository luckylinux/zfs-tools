#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Load files in config-pre/ Folder
mapfile -t files < <( find "${toolpath}/config-pre/" -iname "*.sh" )

# Process files in config-pre/ Folder
for file in "${files[@]}"
do
    source ${file}
done

# Check if config.sh exists
if [[ ! -f "${toolpath}/config.sh" ]]
then
    echo "ERROR: file ${toolpath}/config.sh does NOT exist. Aborting !"
    exit 9
fi

# Load Config File
source ${toolpath}/config.sh

# Load files in config-post/ Folder
mapfile -t files < <( find "${toolpath}/config-post/" -iname "*.sh" )

# Process files in config-post/ Folder
for file in "${files[@]}"
do
    source ${file}
done
