#!/usr/bin/bash
set -e

if [ -f /usr/local/bin/yggdrasil ]; then
    echo "yggdrasil already installed, doing nothing"
else
    echo "installing yggdrasil"
    cd /etc/yggdrasil-go
    git checkout master
    git reset --hard origin/master
    export GOPATH=/tmp/go
    export GOCACHE=/tmp/.cache/go
    ./build
    rm -rf /tmp/go /tmp/.cache/go
    cp yggdrasil /usr/local/bin/yggdrasil
    cp yggdrasilctl /usr/local/bin/yggdrasilctl
    echo "yggdrasil is now installed in /usr/local/bin/yggdrasil"
fi

if [ -f /etc/yggdrasil.conf ]; then
    echo "yggdrasil is already configured, doing nothing"
else
    echo "configuring yggdrasil"
    NODE_PUBLIC_KEY=$(grep ipv6_pubkey /etc/salt/grains | cut -d ' ' -f2)
    NODE_PRIVATE_KEY=$(grep ipv6_privkey /etc/salt/grains | cut -d ' ' -f2)
    IP_ADDRESS_TO_BIND_ON=$(ip -f inet addr show eth0 | grep 'inet ' | head -n 1 | cut -d '/' -f1 | awk '{print$NF}')
    cat << EOF > /tmp/tmp_yggdrasil.conf
{
  "Peers": [
    "tls://{{ pillar['powerdns_static_ip'] }}:5432",
    "tls://{{ pillar['prometheus_static_ip'] }}:5432",
    "tls://{{ pillar['debianrepo_static_ip'] }}:5432",
    "tls://{{ pillar['grafana_static_ip'] }}:5432",
    "tls://{{ pillar['irc_static_ip'] }}:5432",
    "tls://{{ pillar['vmsaltmaster_static_ip'] }}:5432"
  ],
  "InterfacePeers": {},
  "Listen": [
    "tls://$IP_ADDRESS_TO_BIND_ON:5432"
  ],
  "AdminListen": "unix:///var/run/yggdrasil.sock",
  "MulticastInterfaces": [
  ],
  "AllowedPublicKeys": [
EOF
    grep ipv6_allowed_keys /etc/salt/grains | cut -d ' ' -f2 | tr ',' '\n'  | awk '{ printf "    \"%s\",\n", $0 }' | sed '$s/,$//' >> /tmp/tmp_yggdrasil.conf
    cat << EOF >> /tmp/tmp_yggdrasil.conf
  ],
  "PublicKey": "$NODE_PUBLIC_KEY",
  "PrivateKey": "$NODE_PRIVATE_KEY",
  "IfName": "auto",
  "IfMTU": 65535,
  "NodeInfoPrivacy": false,
  "NodeInfo": {
    "homelab_name": "$(hostname)",
    "homelab_role": "$(grep role /etc/salt/grains | cut -d ' ' -f2)"
  }
}
EOF
    mv /tmp/tmp_yggdrasil.conf /etc/yggdrasil.conf
fi
