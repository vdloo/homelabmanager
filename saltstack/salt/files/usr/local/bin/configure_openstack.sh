#!/usr/bin/bash
set -e

cd /opt/stack
if [ -d devstack ]; then
    echo "Devstack already configured"
    exit 0
fi

git clone https://github.com/openstack/devstack.git
cd devstack
git fetch
git checkout stable/wallaby
GIT_BASE_IF_NEEDED=""
if [ -d /mnt/storage/openstack ]; then
    GIT_BASE_IF_NEEDED="GIT_BASE=file:///mnt/storage/openstack"
fi
cat << EOF > local.conf
[[local|localrc]]
$GIT_BASE_IF_NEEDED
PUBLIC_INTERFACE=ens4
FIXED_RANGE=10.11.12.0/24
FIXED_NETWORK_SIZE=256
ADMIN_PASSWORD={{ pillar['openstack_stack_password'] }}
DATABASE_PASSWORD={{ pillar['openstack_stack_password'] }}
RABBIT_PASSWORD={{ pillar['openstack_stack_password'] }}
SERVICE_PASSWORD={{ pillar['openstack_stack_password'] }}
CONFIG_NOVA_SCHED_CPU_ALLOC_RATIO=16.0
CONFIG_NOVA_SCHED_RAM_ALLOC_RATIO=1.5
EOF

FORCE=yes ./stack.sh && echo "Stacking is done!"

echo "Configuring the stack openstack user"
. /opt/stack/devstack/openrc

echo "Setting up security group rules"
openstack security group rule create --proto icmp --dst-port 0 default
openstack security group rule create --proto tcp --dst-port 1:65535 default

echo "Importing Debian Buster image"
mkdir -p /opt/stack/downloaded_images
cd /opt/stack/downloaded_images
if [ -f /mnt/storage/openstack/debian-10-openstack-amd64.raw ]; then
    cp /mnt/storage/openstack/debian-10-openstack-amd64.raw .
else
    wget -q https://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.raw
fi
qemu-img resize debian-10-openstack-amd64.raw +3G
openstack image create --container-format bare --disk-format raw --file debian-10-openstack-amd64.raw debian-10-openstack-amd64
rm -f debian-10-openstack-amd64.raw

echo "Importing Ubuntu Focal image"
if [ -f /mnt/storage/openstack/focal-server-cloudimg-amd64.img ]; then
    cp /mnt/storage/openstack/focal-server-cloudimg-amd64.img .
else
    wget -q https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
fi
qemu-img resize focal-server-cloudimg-amd64.img +5G
openstack image create --container-format bare --disk-format raw --file focal-server-cloudimg-amd64.img focal-server-cloudimg-amd64
rm -f focal-server-cloudimg-amd64.img

echo "Adding keypair"
openstack keypair create --public-key /opt/stack/.ssh/id_rsa.pub homelabkey

echo "Configuring the admin openstack user"
. /opt/stack/devstack/openrc admin admin
echo "Setting quotas"
nova quota-update --ram 64000 $(openstack project list | grep -v alt_demo | grep demo | awk '{print$2}')
nova quota-update --instances 100 $(openstack project list | grep -v alt_demo | grep demo | awk '{print$2}')
nova quota-update --cores 1000 $(openstack project list | grep -v alt_demo | grep demo | awk '{print$2}')
openstack quota set --volumes 1000 $(openstack project list | grep -v alt_demo | grep demo | awk '{print$2}')
openstack quota set --floating-ips 1000 $(openstack project list | grep -v alt_demo | grep demo | awk '{print$2}')
openstack quota set --ports 1000 $(openstack project list | grep -v alt_demo | grep demo | awk '{print$2}')

echo "All done! Go to http://{{ pillar['openstack_static_ip'] }} to log in."
