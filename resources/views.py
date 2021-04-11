from os import environ
from django.http import HttpResponse
from rest_framework.status import HTTP_400_BAD_REQUEST

from resources.models import Resource

QEMU_CONN = """
terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}
"""

SALT_ROLE = """
data "template_file" "{name}_on_{hypervisor}_user_data" {{
  template = <<EOT
#cloud-config
runcmd:
- |
    set -e
    # Obviously you should not do this in any real environment
    echo "root:toor" | chpasswd
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
    
    # Configure the hostname
    echo {name}-on-{hypervisor} > /etc/hostname
    echo "127.0.0.1\tlocalhost" > /etc/hosts
    echo "127.0.0.1\t{name}-on-{hypervisor}" >> /etc/hosts
    
    if [ -f "/etc/arch-release" ]; then
        echo 'Server = http://mirror.nl.leaseweb.net/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
        pacman -Syyu salt cloud-utils e2fsprogs --noconfirm --overwrite /usr/bin/growpart
    else
        apt-get update
        apt-get install curl -y
        
        # Resize disk and install SaltStack
        if lsb_release -c | grep -q focal; then
            curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" > /etc/apt/sources.list.d/salt.list
        else
            curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/debian/10/amd64/latest/salt-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltproject.io/py3/debian/10/amd64/latest buster main" > /etc/apt/sources.list.d/salt.list
        fi
        
        apt-get update
        apt-get install cloud-guest-utils e2fsprogs salt-minion  -y
    fi
    
    growpart /dev/vda 1 || /bin/true
    resize2fs /dev/vda1 || /bin/true
    echo "master: {vm_saltmaster}" > /etc/salt/minion
    echo "role: {role}" > /etc/salt/grains
    echo "hypervisor: {hypervisor}" >> /etc/salt/grains
    systemctl stop salt-minion || /bin/true
    systemctl enable salt-minion || /bin/true
    rm -f /etc/salt/minion_id
    
    # Delete the cloud-config config and reboot
    rm -f /etc/cloud/cloud.cfg
    reboot

manage_etc_hosts: False
preserve_hostname: True
EOT
}}

resource "libvirt_cloudinit_disk" "{name}_on_{hypervisor}_commoninit" {{
  name           = "{name}_on_{hypervisor}_commoninit.iso"
  user_data      = data.template_file.{name}_on_{hypervisor}_user_data.rendered
}}
"""

VOLUME = """
resource "libvirt_volume" "{name}_on_{hypervisor}-qcow2" {{
  provider = libvirt
  pool = "default"
  name = "{name}_on_{hypervisor}-qcow2"
  source = "/var/lib/libvirt/images/{image}"
}}

resource "libvirt_volume" "{name}_on_{hypervisor}-extra-qcow2" {{
  provider = libvirt
  pool = "storage"
  name = "{name}_on_{hypervisor}-extra-qcow2"
  size   = 8053063680
}}


"""

NODE = """
resource "libvirt_domain" "{name}_on_{hypervisor}" {{
  provider = libvirt
  name = "{name}_on_{hypervisor}"
  memory = "{ram}"
  vcpu = {cpu}
  cloudinit = libvirt_cloudinit_disk.{name}_on_{hypervisor}_commoninit.id
  
  network_interface {{
    macvtap = "{interface}"
  }}
  console {{
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }}

  console {{
    type        = "pty"
    target_type = "virtio"
    target_port = "1"
  }}

  boot_device {{
    dev = ["hd"]
  }}
  disk {{
    volume_id = libvirt_volume.{name}_on_{hypervisor}-qcow2.id
  }}
  disk {{
    volume_id = libvirt_volume.{name}_on_{hypervisor}-extra-qcow2.id
  }}
  graphics {{
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }}
  video {{
    type = "qxl"
  }}
}}
"""


def get_vm_saltmaster_ip():
    """
    Return the VM Saltmaster IP
    :return str vm_saltmaster_ip: The VM saltmaster IP
    """
    vm_saltmaster_ip = environ.get("VM_SALTMASTER_IP", "127.0.0.1")
    return vm_saltmaster_ip


def generate_cloud_init_configuration(hypervisor_name):
    """
    Generate cloud-init configuration. This terraform
    configuration creates a small disk with a file on
    it to configure cloud-init during boot.
    :param str hypervisor_name: The name of a hypervisor
    :return str configuration: The configuration segment
    """
    relevant_resources = Resource.objects.filter(
        host=hypervisor_name
    )
    cloud_init_config = ""
    for relevant_resource in relevant_resources:
        cloud_init_config += SALT_ROLE.format(
            role=relevant_resource.role,
            name=relevant_resource.name,
            hypervisor=relevant_resource.host,
            vm_saltmaster=get_vm_saltmaster_ip()
        )
    return cloud_init_config


def get_node_and_volumes(hypervisor_name):
    """
    Generate the instance and disk terraform configuration
    so that these resources can be created using libvirt.
    :param str hypervisor_name: The name of the hypervisor
    for which to get the config for.
    :return str configuration: The configuration segment
    """
    node_and_vol_config = ""
    for node in Resource.objects.filter(host=hypervisor_name):
        node_and_vol_config += VOLUME.format(
            name=node.name,
            image=node.image,
            hypervisor=hypervisor_name
        )
        node_and_vol_config += NODE.format(
            name=node.name,
            ram=node.ram_in_mb,
            interface=node.interface,
            cpu=node.cpu,
            role=node.role,
            hypervisor=hypervisor_name
        )
    return node_and_vol_config


def terraform(request):
    """
    Generate the terraform configuration for a hypervisor
    :param obj request: The Django request object
    :return object HttpResponse: The Django HttpResponse
    """
    hypervisor_name = request.GET.get('host')
    if not hypervisor_name:
        return HttpResponse(
            "You must specify ?host=<hypervisor_name>",
            status=HTTP_400_BAD_REQUEST, content_type="test/plain"
        )

    out = QEMU_CONN
    out += generate_cloud_init_configuration(hypervisor_name)
    out += get_node_and_volumes(hypervisor_name)
    return HttpResponse(out, content_type="text/plain")
