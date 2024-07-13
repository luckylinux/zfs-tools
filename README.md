# zfs-tools
ZFS Pool Tools

# Quick Updates
Initialize:
```
cd /tools_local/zfs-tools/
git clone https://github.com/luckylinux/zfs-tools.git
cd zfs-tools
systemctl disable zfs-auto-unlock-import-pool@zdata.service
systemctl stop zfs-auto-unlock-import-pool@zdata.service
git pull
bash setup_services.sh 
systemctl enable zfs-auto-unlock-import-all.service
```

Update: 
```
cd /tools_local/zfs-tools/ ; git pull ; ./setup_services.sh
```
