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
