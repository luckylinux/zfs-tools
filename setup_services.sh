#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing "${scriptpath}/${relativepath}"); fi

# Load Functions
source "${toolpath}/functions.sh"

# Setup All Services
source "${toolpath}/setup_all_pools_sync_service.sh"
source "${toolpath}/setup_all_pools_import_service.sh"
source "${toolpath}/setup_single_pool_import_service.sh"
