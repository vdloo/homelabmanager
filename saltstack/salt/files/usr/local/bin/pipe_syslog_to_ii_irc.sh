#!/usr/bin/bash
set -e

while true; do
    if [ -p /tmp/homelabirc/{{pillar['irc_static_ip'] }}/#homelabstatus/in ]; then
        tail -n 0 -f /var/log/syslog > '/tmp/homelabirc/{{pillar['irc_static_ip'] }}/#homelabstatus/in'
    fi
    sleep 10
done
