#!/bin/bash

# Determine toolpath if not set already
relativepath="./" # Define relative path to go from this script to the root level of the tool
if [[ ! -v toolpath ]]; then scriptpath=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd ); toolpath=$(realpath --canonicalize-missing $scriptpath/$relativepath); fi

# Define filename
filename="/etc/cron.d/disable-automatic-mounting-backup-snapshots"

# Write to file
tee $filename << EOF
0 * * * * root /tools_local/disable_automatic_mounting_backup_snapshots.sh
EOF

# Make it executable
chmod +x $filename

