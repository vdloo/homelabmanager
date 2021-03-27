# Setting up a development environment

These are some notes regarding setting up a development environment. This example uses `Ubuntu 20.04.2 LTS`.

1. Create 4 VMS or physical servers

For example:
```
192.168.1.36 homelabmanager
192.168.1.28 hypervisor
192.168.1.37 saltmaster vms
```

2. Run homelabmanager on the first machine

```
# apt-get install python3-pip python3-venv -yy
# git clone https://github.com/vdloo/homelabmanager.git
# cd homelabmanager
# python3 -m venv venv
# . venv/bin/activate
# pip3 install -r requirements/dev.txt
# ./manage.py migrate
# export VM_SALTMASTER_IP=192.168.1.37
# ./manage.py runserver 0.0.0.0:4424
```

And then add a new resource on 192.168.1.36:4424/admin that has as the host the hostname of the hypervisor. For example:
```
Name: test
Interface: ens3
Ram in mb: 1024
Cpu: 2
Host: hypervisor
Role: test
Profile: test
Image: focal-server-cloudimg-amd64.img
```
3. Set up the VM saltmaster

Set up the saltmaster so the VMs can connect. Note that the VMs on your hypervisor need to be able to access this server, so if you're nesting hypervisor on top of hypervisor and use macvtap everywhere things might get messy.
```
# apt-get install salt-master -y
# # Obviously never configure a Saltmaster like this in any real environment
# cat << 'EOF' > /etc/salt/master
# open_mode: True
# auto_accept: True
# reactor:
#   - 'salt/minion/*/start':
#     - /srv/reactor/salt.sls
# EOF
# mkdir -p /srv/reactor/
# cat << 'EOF' > /srv/reactor/salt.sls
# highstate_run:
#     local.state.apply:
#         - tgt: {{ data['id'] }}
# EOF
# mkdir -p /srv/salt/
# cat << 'EOF' > /srv/salt/top.sls
# base:
#   '*':
#     - core
# EOF
# cat << 'EOF' > /srv/salt/core.sls
# install_core_packages:
#   pkg.installed:
#     - pkgs:
#       - cmatrix
#     - refresh: true
# EOF
# systemctl restart salt-master
# echo "*/2 * * * * salt-run manage.down removekeys=True > /dev/null 2>&1" | crontab -
```


4. On the hypervisor run the homelabmanagerslave script

First set up KVM / terraform:
```
# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
# apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"

# echo 'deb http://download.opensuse.org/repositories/systemsmanagement:/terraform/Ubuntu_20.04/ /' | tee /etc/apt/sources.list.d/systemsmanagement:terraform.list
# curl -fsSL https://download.opensuse.org/repositories/systemsmanagement:terraform/Ubuntu_20.04/Release.key | gpg --dearmor | tee /etc/apt/trusted.gpg.d/systemsmanagement_terraform.gpg > /dev/null
# apt-get update

# apt-get install moreutils qemu-kvm libvirt-daemon-system libvirt-clients libvirt-dev virt-manager bridge-utils terraform mkisofs terraform-provider-libvirt -y
# echo "security_driver = "none" > /etc/libvirt/qemu.conf
# systemctl restart libvirtd
# systemctl enable libvirtd
```

Set up libvirt:
```
# mkdir -p /mnt/disk/images
# mkdir -p /mnt/disk/storage
# cat << 'EOF' > /tmp/default.xml
# <pool type='dir'>
#   <name>default</name>
#   <uuid>12345678-1234-1234-1234-123456789012</uuid>
#   <source>
#   </source>
#   <target>
#     <path>/mnt/disk/images</path>
#     <permissions>
#       <mode>0755</mode>
#       <owner>0</owner>
#       <group>0</group>
#     </permissions>
#   </target>
# </pool>
# EOF
# cat << 'EOF' > /tmp/storage.xml
# <pool type='dir'>
#   <name>storage</name>
#   <uuid>22345678-1234-1234-1234-123456789012</uuid>
#   <source>
#   </source>
#   <target>
#     <path>/mnt/disk/storage</path>
#     <permissions>
#       <mode>0755</mode>
#       <owner>0</owner>
#       <group>0</group>
#     </permissions>
#   </target>
# </pool>
# EOF
# virsh pool-destroy default || /bin/true
# virsh pool-create /tmp/default.xml
# virsh pool-create /tmp/storage.xml
# wget -O /var/lib/libvirt/images/focal-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img -nc
## Or if you want VMs based on Buster
##  wget -O /var/lib/libvirt/images/debian-10-openstack-amd64.qcow2 http://cdimage.debian.org/cdimage/openstack/current-10/debian-10-openstack-amd64.qcow2 -nc
## Or based on Archlinux
##  wget -O /var/lib/libvirt/images/arch-openstack-LATEST-image-bootstrap.qcow2 https://linuximages.de/openstack/arch/arch-openstack-LATEST-image-bootstrap.qcow2
# qemu-img resize /var/lib/libvirt/images/focal-server-cloudimg-amd64.img +10G
```

Then install the client
```
# git clone https://github.com/vdloo/homelabmanager.git
# cd homelabmanager/homelabmanagerslave
# cp homelabmanager.sh /root/
# chmod +x /root/homelabmanager.sh
# cp homelabmanagerslave.service /etc/systemd/system/
# sed -i -e 's/<some_host>/192.168.1.36/g' /etc/systemd/system/homelabmanagerslave.service
# echo '#!/bin/bash' > /root/ramdisk.sh # set up a ramdisk mount here if you want
# chmod +x /root/ramdisk.sh
```

To run the refresh manually:
```
# export HOMELABMANAGERHOST=192.168.1.36
# # If you are not intending to use (nested) KVM do: 
# export TERRAFORM_LIBVIRT_TEST_DOMAIN_TYPE="qemu"
# bash -x /root/homelabmanager.sh  # If you get 'Could not load plugin' run it again
```
