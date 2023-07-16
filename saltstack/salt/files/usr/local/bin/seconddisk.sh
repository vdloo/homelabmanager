#!/bin/bash
set -e

# Format disk
if [ ! -d /mnt/disk ]; then
    (echo o; echo n; echo p; echo 1; echo ""; echo ""; echo w; echo q) | fdisk /dev/vdb; mkfs.ext4 /dev/vdb1
    mkdir -p /mnt/disk
fi

if ! mount | grep -q "vdb1"; then
    mount -t auto /dev/vdb1 /mnt/disk
fi

if ! grep -q vdb1 /etc/fstab; then
    echo "/dev/vdb1    /mnt/disk    ext4    defaults    0    1" >> /etc/fstab
fi

if ! test -L /var/lib/docker; then
    systemctl stop docker || /bin/true
    rm -rf /var/lib/docker
    mkdir -p /mnt/disk/docker
    ln -s /mnt/disk/docker /var/lib/docker
    systemctl restart docker || /bin/true
fi
