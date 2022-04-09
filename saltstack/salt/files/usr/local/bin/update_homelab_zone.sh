#!/bin/bash
set -e
until which pdnsutil &> /dev/null
do
    echo "Waiting for pdnsutil to be installed.."
    sleep 1
done
pdnsutil delete-zone homelab || /bin/true
pdnsutil create-zone homelab ns1.homelab
pdnsutil add-record homelab router A 192.168.1.1
pdnsutil add-record homelab powerdns A {{ pillar['powerdns_static_ip'] }}
pdnsutil add-record homelab dns A {{ pillar['powerdns_static_ip'] }}
pdnsutil add-record homelab debianrepo A {{ pillar['debianrepo_static_ip'] }}
pdnsutil add-record homelab grafana A {{ pillar['grafana_static_ip'] }}
pdnsutil add-record homelab prometheus A {{ pillar['prometheus_static_ip'] }}
pdnsutil add-record homelab irc A {{ pillar['irc_static_ip'] }}
pdnsutil add-record homelab vmsaltmaster A {{ pillar['vmsaltmaster_static_ip'] }}
pdnsutil add-record homelab openstack A {{ pillar['openstack_static_ip'] }}

cat << 'EOF' > /tmp/set_records_for_yggdrasil_peers.py
#!/usr/bin/env python3
import json
from contextlib import suppress
from subprocess import check_output
current_peers = check_output("yggdrasilctl getPeers | cut -d ']' -f2", shell=True)
for current_peer in current_peers.decode('utf-8').split('\n'):
    if not current_peer or 'key' in current_peer:
        continue
    with suppress():
        parts = current_peer.split()
        key = parts[0]
        ip = parts[2]
        raw_nodeinfo = check_output(
            "yggdrasilctl getnodeinfo key={}".format(key), 
            shell=True
        )
        nodeinfo = json.loads(raw_nodeinfo)
        for ipv6_ip, info in nodeinfo.items():
            role = info.get('homelab_role')
            name = info.get('homelab_name')
            if not role or not name:
                continue
            check_output(
                "pdnsutil add-record homelab {} AAAA {}".format(role, ipv6_ip),
                shell=True
            )
            short_name = name.split('-')[0]
            check_output(
                "pdnsutil add-record homelab {} AAAA {}".format(short_name, ipv6_ip),
                shell=True
            )
            break
EOF
python3 /tmp/set_records_for_yggdrasil_peers.py
