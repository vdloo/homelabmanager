#!/usr/bin/bash
set -e
if [ -f /etc/systemd/network/01-homelab.network ]; then
    sed -i "s/DNS=8.8.8.8/{{ pillar['powerdns_upstream_nameserver_1'] }}/g" /etc/systemd/network/eth0-dhcp.network
    sed -i "s/DNS=8.8.4.4/{{ pillar['powerdns_upstream_nameserver_2'] }}/g" /etc/systemd/network/eth0-dhcp.network
fi
if [ -f /etc/network/interfaces ]; then
    sed -i "s/dns-nameservers 8.8.8.8 8.8.4.4/dns-nameservers {{ pillar['powerdns_upstream_nameserver_1'] }} {{ pillar['powerdns_upstream_nameserver_2'] }}/g" /etc/network/interfaces
fi
