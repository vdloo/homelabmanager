#!/bin/bash
set -e

if [ -z "$HOMELABMANAGERHOST" ]; then
    echo "You need to set HOMELABMANAGERHOST in your environment"
    exit 1
fi

export LIBVIRT_DEFAULT_URI="qemu:///system"

# TODO: make nicer
mkdir -p /tmp/terraform
cd /tmp/terraform
touch checksum
chronic terraform init || /bin/true
chronic wget "$HOMELABMANAGERHOST:4424/terraform/?host=$(hostname)" -O main.tf
chronic terraform validate
if ! cat checksum | md5sum --quiet -c; then
    md5sum main.tf > checksum
    terraform destroy --auto-approve
    virsh list --all | grep -v debian10 | grep -v ubuntu18 | grep -v focal | grep shut | awk '{print$2}' | xargs -I {} sh -c 'virsh destroy {} || /bin/true; virsh undefine {} || /bin/true' || /bin/true
    cd /var/lib/libvirt/images
    ls /var/lib/libvirt/images | grep -v bionic-server | grep -v debian-10 | grep -v focal-server-cloudimg | xargs -I {} rm -rf "{}"
    cd -
    terraform apply --auto-approve
fi
