#!/usr/bin/bash
set -e
if ! hostname | grep -q powerdns; then
    timeout 1 bash -c "</dev/tcp/{{ pillar['powerdns_static_ip'] }}/53 && echo nameserver {{ pillar['powerdns_static_ip'] }} > /etc/resolv.conf" \
        || bash -c "echo nameserver {{ pillar['powerdns_upstream_nameserver_1'] }} > /etc/resolv.conf"
fi
