#!/bin/bash

# Define filename
filename="/etc/cron.d/disable-automatic-mounting-backup-snapshots"

# Write to file
tee $filename << EOF
0 * * * * root /tools_local/disable_automatic_mounting_backup_snapshots.sh
EOF

# Make it executable
chmod +x $filename

