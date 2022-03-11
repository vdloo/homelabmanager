#!/usr/bin/bash
set -e

if [ ! -d /etc/yggdrasil-go ]; then
    echo "No yggdrasil on this machine, skipping consul configuration"
    exit 0
fi

if [ -f /etc/consul.d/config.json ]; then
    echo "consul already configured, doing nothing"
    exit 0
fi

echo "configuring consul"
mkdir -p /etc/consul.d/

until [ ! -z "$IPV6_ADDRESS" ] ; do 
    echo "Will try to detect the IPv6 address in a bit"
    sleep 1
    IPV6_ADDRESS="$(ip addr | grep inet6 | grep global | cut -d ' ' -f6 | cut -d '/' -f1 | head -n 1)"
done

SHARED_SECRET="{{ pillar['consul_secret'] }}"
NODE_ID="$(/usr/local/bin/uuid_from_string.py $IPV6_ADDRESS)"
IPS_TO_JOIN=$(grep ipv6_allowed_ips /etc/salt/grains | cut -d ' ' -f2 | tr ',' '\n'  | awk '{ printf "    \"%s\",\n", $0 }' | sed '$s/,$//' | tr '\n' ' ')
cat << EOF > /tmp/tmp_consul_config.json
{
  "bootstrap_expect": 3,
  "data_dir": "/opt/consul",
  "datacenter": "homelab",
  "log_level": "INFO",
  "node_name": "$HOSTNAME",
  "node_id": "$NODE_ID",
  "server": true,
  "bind_addr": "::",
  "advertise_addr": "$IPV6_ADDRESS",
  "encrypt": "$SHARED_SECRET",
  "disable_remote_exec": true,
  "enable_script_checks": false,
  "performance": {
    "raft_multiplier": 10
  },
  "dns_config": {
    "allow_stale": true,
    "recursor_timeout": "1s"
  },
  "leave_on_terminate": true,
  "ui": true,
  "skip_leave_on_interrupt": false,
  "disable_update_check": true,
  "reconnect_timeout": "8h",
  "reconnect_timeout_wan": "8h",
  "translate_wan_addrs": false,
  "rejoin_after_leave": true,
  "retry_join": [$IPS_TO_JOIN]
}
EOF
if [[ "$(md5sum /etc/consul.d/config.json || echo)" != "$(md5sum /tmp/tmp_consul_config.json || echo)" ]]; then
    mv /tmp/tmp_consul_config.json /etc/consul.d/config.json
    systemctl restart consul
fi
