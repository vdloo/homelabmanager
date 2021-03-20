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
data "template_file" "{role}_user_data" {{
  template = <<EOT
#cloud-config
write_files:
-   content: "role: {role}"
    owner: root:root
    path: /etc/salt/grains
    permissions: '0644'
-   content: ""
    owner: root:root
    path: /etc/cloud/cloud.cfg
    permissions: '0644'
manage_etc_hosts: False
preserve_hostname: True
EOT
}}

resource "libvirt_cloudinit_disk" "{role}_commoninit" {{
  name           = "{role}_commoninit.iso"
  user_data      = data.template_file.{role}_user_data.rendered
}}
"""

VOLUME = """
resource "libvirt_volume" "{name}-qcow2" {{
  provider = libvirt
  pool = "default"
  name = "{name}-qcow2"
  source = "/var/lib/libvirt/images/{image}"
}}

resource "libvirt_volume" "{name}-extra-qcow2" {{
  provider = libvirt
  pool = "storage"
  name = "{name}-extra-qcow2"
  size   = 32212254720
}}


"""

NODE = """
resource "libvirt_domain" "{name}" {{
  provider = libvirt
  name = "{name}"
  memory = "{ram}"
  vcpu = {cpu}
  cloudinit = libvirt_cloudinit_disk.{role}_commoninit.id
  
  network_interface {{
    macvtap = "{interface}"
  }}
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
    volume_id = libvirt_volume.{name}-qcow2.id
  }}
  disk {{
    volume_id = libvirt_volume.{name}-extra-qcow2.id
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
    roles = set([x.role for x in relevant_resources])
    for role in roles:
        cloud_init_config += SALT_ROLE.format(role=role)
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
            image=node.image
        )
        node_and_vol_config += NODE.format(
            name=node.name, ram=node.ram_in_mb,
            interface=node.interface, cpu=node.cpu, role=node.role
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
