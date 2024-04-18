# Troubleshooting
## Introduction
This Section contain Tips to Solve Dataset/Pool is Busy Error Messages.

`lsof` unfortunately never worked for me troubleshooting ZFS Dataset/Pool is Busy related Issues.

## Tips for Datasets
```
# Dataset to be destroy
DATASET="zdata/TEST"

# Sequence of Attempts
root@HOSTNAME:~# zfs destroy "${DATASET}"
cannot destroy 'zdata/TEST': dataset is busy

root@HOSTNAME:~# zfs list -t snapshot | grep -i "${DATASET}"
zdata/TEST@zfs-auto-snap_frequent-2024-04-18-1415             0B      -    96K  -

root@HOSTNAME:~# zfs destroy "${DATASET}"@zfs-auto-snap_frequent-2024-04-18-1415

root@HOSTNAME:~# zfs destroy "${DATASET}"
cannot destroy 'zdata/TEST': dataset is busy

root@HOSTNAME:~#  zfs get mountpoint | grep -i "${DATASET}"  | grep -v @
zdata/TEST                                                 mountpoint  /zdata/TEST          inherited from zdata

# This is what FINALLY Fixes it
root@HOSTNAME:~# zfs set mountpoint=none "${DATASET}"
root@HOSTNAME:~# zfs set canmount=off "${DATASET}"
root@HOSTNAME:~# zfs umount "${DATASET}"
cannot unmount 'zdata/TEST': not currently mounted
root@HOSTNAME:~# zfs destroy "${DATASET}"
# No Error :)

# Continue with what you need to do
root@HOSTNAME:~# zfs list
```

Alternatively you might also try using findmnt to find if the dataset is used/mounted/referenced:
```
# Search in static table of filesystems (FSTAB file)
findmnt -l -s --types zfs --output target

# Search in table of mounted filesystems (includes user space mount options)
findmnt -l -m --types zfs --output target

# Search in kernel table of mounted filesystems (default)
findmnt -l -k --types zfs --output target
```

## Tips for ZVOLs

```
# ZVOL to be Destroyed
ZVOL="vm-123"

# Try to see if any process is accessing your device
ps aux | grep -i "zvol"
ps aux | grep -i "${ZVOL}"

# Try to see if there is some configuration still referencing them (and potentially e.g. Proxmox VE processes blocking them)
grep -ri "${ZVOL}" /etc/pve/
grep -ri "${ZVOL}" /etc/

# Try to see if there are any read/writes to the concered device
iostat --human --pretty

# Or using iotop in batch mode
logfile="test.log"
iotop --batch > "${logfile}"
cat "${logfile}" | grep -i "zvol" | grep -i "${ZVOL}"
```

## References
Useful References:
- https://unix.stackexchange.com/questions/86875/determining-specific-file-responsible-for-high-i-o
