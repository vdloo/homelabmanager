from os import environ
from django.http import HttpResponse
from rest_framework.status import HTTP_400_BAD_REQUEST

from resources.models import VirtualMachine, Profile

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
    
    if lsb_release -d | grep -q buster; then
        echo "auto lo" > /etc/network/interfaces
        echo "iface lo inet loopback" >> /etc/network/interfaces
        echo "auto eth0" >> /etc/network/interfaces
        if [ ! -z "{static_ip}" ]; then
            echo "iface eth0 inet static" >> /etc/network/interfaces
            echo "  address {static_ip}" >> /etc/network/interfaces
            echo "  netmask 255.255.255.0" >> /etc/network/interfaces
            echo "  gateway 192.168.1.1" >> /etc/network/interfaces
            echo "  dns-nameservers 1.1.1.1 1.0.0.1" >> /etc/network/interfaces
        else
            echo "iface eth0 inet dhcp" >> /etc/network/interfaces
        fi
    else
        if lsb_release -d | grep -q Debian; then
            # To use systemd-networkd directly on Bookworm
            apt-get purge netplan.io -y || /bin/true
        fi
        systemctl stop systemd-resolved || /bin/true
        systemctl disable systemd-resolved || /bin/true
        rm -rf /etc/resolv.conf
        echo "nameserver 1.1.1.1" > /etc/resolv.conf
        echo "nameserver 1.0.0.1" >> /etc/resolv.conf
        IFACE_NAME="ens3"
        if [ -f "/etc/arch-release" ]; then
            IFACE_NAME="eth0"
        fi
        rm -rf /etc/systemd/network/*.network
        echo "[Match]" > /etc/systemd/network/01-homelab.network
        echo "Name=$IFACE_NAME" >> /etc/systemd/network/01-homelab.network
        echo "[Network]" >> /etc/systemd/network/01-homelab.network
        if [ ! -z "{static_ip}" ]; then
            echo "Address={static_ip}/24" >> /etc/systemd/network/01-homelab.network
            echo "Gateway=$(echo {static_ip} | cut -d'.' -f1-3).1" >> /etc/systemd/network/01-homelab.network
            echo "DNS=1.1.1.1" >> /etc/systemd/network/01-homelab.network
            echo "DNS=1.0.0.1" >> /etc/systemd/network/01-homelab.network
            echo "UseRoutes=False" >> /etc/systemd/network/01-homelab.network
        else
            echo "DHCP=yes" >> /etc/systemd/network/01-homelab.network
        fi
    fi
    
    # TODO: make the router(s) push the default gateway properly and remove this workaround
    # Fix routes on subnets if default gateway incorrect
    echo '#/usr/bin/bash' > /usr/local/bin/fix_subnet_routes.sh
    echo 'sleep 5' >> /usr/local/bin/fix_subnet_routes.sh
    echo 'ALT_GATEWAY=$(ip route | grep "link src" | tail -n 1 | head -n 1 | cut -d "/" -f1 | sed "s/\.0/\.1/g" | grep -v 192.168.1.1 | cut -d " " -f1)' >> /usr/local/bin/fix_subnet_routes.sh
    echo 'test ! -z "$ALT_GATEWAY" && (ip route del default via 192.168.1.1 || /bin/true; ip route add default via $ALT_GATEWAY || /bin/true) || /bin/true' >> /usr/local/bin/fix_subnet_routes.sh
    chmod u+x /usr/local/bin/fix_subnet_routes.sh
    /usr/local/bin/fix_subnet_routes.sh
    echo '[Service]' > /lib/systemd/system/fix_routes.service
    echo 'ExecStart=/usr/bin/bash /usr/local/bin/fix_subnet_routes.sh' >> /lib/systemd/system/fix_routes.service
    echo 'Type=oneshot' >> /lib/systemd/system/fix_routes.service
    echo '[Install]' >> /lib/systemd/system/fix_routes.service
    echo 'WantedBy=multi-user.target' >> /lib/systemd/system/fix_routes.service
    systemctl daemon-reload
    systemctl enable fix_routes.service
    systemctl restart systemd-networkd

    # Wait until we have network
    while ! ping -c 3 1.1.1.1; do sleep 1; done
    
    # Configure the hostname
    echo {name}-on-{hypervisor} > /etc/hostname
    echo "127.0.0.1\tlocalhost" > /etc/hosts
    echo "127.0.0.1\t{name}-on-{hypervisor}" >> /etc/hosts
    
    if [ -f "/etc/arch-release" ]; then
        echo 'Server = http://mirror.nl.leaseweb.net/archlinux/$repo/os/$arch' > /etc/pacman.d/mirrorlist
        rm -rf /etc/pacman.d/gnupg
        pacman-key --init
        pacman-key --populate archlinux
        pacman -Syy
        pacman -S gnupg archlinux-keyring --noconfirm
        pacman -Su cloud-utils e2fsprogs python-tornado base-devel git --noconfirm --overwrite /usr/bin/growpart
        sudo -u arch bash -c "cd; git clone https://aur.archlinux.org/yay.git; cd yay; makepkg -si --noconfirm"
        sudo -u arch yay -S salt --noconfirm
        # Workaround for fixing broken Python 3.13 support in salt
        # See https://github.com/saltstack/salt/pull/67788
        wget -q https://raw.githubusercontent.com/saltstack/salt/8a8fc0814264364de2928aeb1207226d18b6f2f8/salt/modules/linux_shadow.py -O /usr/lib/python3.13/site-packages/salt/modules/linux_shadow.py
        userdel arch
        rm -rf /home/arch
    else
        apt-get update --allow-releaseinfo-change
        apt-get install curl -y
        
        # Resize disk and install SaltStack
        if lsb_release -c | grep -q focal; then
            curl -fsSL -o /usr/share/keyrings/salt-archive-keyring.gpg https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest/salt-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/salt-archive-keyring.gpg] https://repo.saltproject.io/py3/ubuntu/20.04/amd64/latest focal main" > /etc/apt/sources.list.d/salt.list
        elif lsb_release -c | grep -q jammy; then
            curl -fsSL -o /etc/apt/keyrings/salt-archive-keyring-2023.gpg https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/SALT-PROJECT-GPG-PUBKEY-2023.gpg
            echo "deb [signed-by=/etc/apt/keyrings/salt-archive-keyring-2023.gpg arch=amd64] https://repo.saltproject.io/salt/py3/ubuntu/22.04/amd64/latest jammy main" > /etc/apt/sources.list.d/salt.list
        else
            curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | tee /etc/apt/keyrings/salt-archive-keyring.pgp
            curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | tee /etc/apt/sources.list.d/salt.sources
            if timeout 1 bash -c "</dev/tcp/192.168.1.252/80"; then
                echo "deb [trusted=yes] http://192.168.1.252 bookworm main" > /tmp/temp_apt_sources.list
                echo "deb [trusted=yes] http://192.168.1.252 bookworm-updates main" >> /tmp/temp_apt_sources.list
            else
                echo "deb http://deb.debian.org/debian/ bookworm main" > /tmp/temp_apt_sources.list
                echo "deb http://deb.debian.org/debian/ bookworm-updates main" >> /tmp/temp_apt_sources.list
            fi
            mv /tmp/temp_apt_sources.list /etc/apt/sources.list
        fi
        
        apt-get update
        apt-get install cloud-guest-utils e2fsprogs salt-minion  -y
    fi
    
    growpart /dev/vda 1 || /bin/true
    resize2fs /dev/vda1 || /bin/true
    echo "master: {vm_saltmaster}" > /etc/salt/minion
    echo "tcp_keepalive: True" >> /etc/salt/minion
    echo "tcp_keepalive_idle: 30" >> /etc/salt/minion
    echo "tcp_keepalive_cnt: 5" >> /etc/salt/minion
    echo "tcp_keepalive_intvl: 30" >> /etc/salt/minion
    echo "recon_default: 1000" >> /etc/salt/minion
    echo "recon_max: 59000" >> /etc/salt/minion
    echo "recon_randomize: True" >> /etc/salt/minion
    echo "acceptance_wait_time: 120" >> /etc/salt/minion
    echo "random_reauth_delay: 90" >> /etc/salt/minion
    echo "auth_timeout: 120" >> /etc/salt/minion
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
network:
  config: disabled
EOT
}}

resource "libvirt_cloudinit_disk" "{name}_on_{hypervisor}_commoninit" {{
  name           = "{name}_on_{hypervisor}_commoninit.iso"
  user_data      = data.template_file.{name}_on_{hypervisor}_user_data.rendered
}}
"""

VOLUME = """
resource "libvirt_volume" "{name}_on_{hypervisor}" {{
  provider = libvirt
  pool = "default"
  name = "{name}_on_{hypervisor}"
  source = "/var/lib/libvirt/images/{image}"
}}

resource "libvirt_volume" "{name}_on_{hypervisor}-extra" {{
  provider = libvirt
  pool = "{extra_storage_pool}"
  name = "{name}_on_{hypervisor}-extra"
  size   = {extra_storage_in_kb}
  format = "raw"
}}


"""

NODE_NIC = """
  network_interface {{
    macvtap = "{interface}"
  }}
"""
NODE = """
resource "libvirt_domain" "{name}_on_{hypervisor}" {{
  provider = libvirt
  name = "{name}_on_{hypervisor}"
  memory = "{ram}"
  vcpu = {cpu}

  cloudinit = libvirt_cloudinit_disk.{name}_on_{hypervisor}_commoninit.id
  
  {nic_config}

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

  cpu {{
    mode = "host-passthrough"
  }}

  boot_device {{
    dev = ["hd"]
  }}
  disk {{
    volume_id = libvirt_volume.{name}_on_{hypervisor}.id
  }}
  disk {{
    volume_id = libvirt_volume.{name}_on_{hypervisor}-extra.id
  }}
  graphics {{
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }}
  video {{
    type = "qxl"
  }}
  xml {{
    xslt = <<EOF
<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>
  <xsl:template match="node()|@*">
      <xsl:copy>
         <xsl:apply-templates select="node()|@*"/>
      </xsl:copy>
   </xsl:template>

  <xsl:template match="/domain/devices">
    <xsl:copy>
        <xsl:apply-templates select="node()|@*"/>
            <xsl:element name="input">
                <xsl:attribute name="type">tablet</xsl:attribute>
                <xsl:attribute name="bus">virtio</xsl:attribute>
                <xsl:element name="address">
                    <xsl:attribute name="type">pci</xsl:attribute>
                    <xsl:attribute name="domain">0x0000</xsl:attribute>
                    <xsl:attribute name="bus">0x00</xsl:attribute>
                    <xsl:attribute name="slot">0x09</xsl:attribute>
                    <xsl:attribute name="function">0x0</xsl:attribute>
                </xsl:element>
                <xsl:element name="alias">
                    <xsl:attribute name="name">input2</xsl:attribute>
                </xsl:element>
            </xsl:element>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
EOF
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
    relevant_resources = VirtualMachine.objects.filter(
        host__name=hypervisor_name,
        enabled=True,
        profile=Profile.objects.filter(enabled=True).first()
    )
    cloud_init_config = ""
    for relevant_resource in relevant_resources:
        cloud_init_config += SALT_ROLE.format(
            role=relevant_resource.role,
            name=relevant_resource.name,
            static_ip=relevant_resource.static_ip or '',
            hypervisor=relevant_resource.host.name,
            vm_saltmaster=relevant_resource.saltmaster_ip or get_vm_saltmaster_ip(),
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
    for node in VirtualMachine.objects.filter(
        host__name=hypervisor_name,
        enabled=True,
        profile=Profile.objects.filter(enabled=True).first()
    ):
        node_and_vol_config += VOLUME.format(
            name=node.name,
            image=node.image,
            hypervisor=hypervisor_name,
            extra_storage_in_kb=node.extra_storage_in_gb * 1024 ** 3,
            extra_storage_pool=node.extra_storage_pool
        )
        nic_config = NODE_NIC.format(interface=node.host.interface) * node.network_interface_count
        node_and_vol_config += NODE.format(
            name=node.name,
            ram=node.ram_in_mb,
            cpu=node.cpu,
            nic_config=nic_config,
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
