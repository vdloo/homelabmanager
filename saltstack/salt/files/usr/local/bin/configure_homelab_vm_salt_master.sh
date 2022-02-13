#!/usr/bin/bash
set -e

if ! test -d /etc/homelabmanager; then
    echo "No checkout of homelabmanager in /etc/homelabmanager yet!"
    exit 1
fi

rm -rf /srv/salt
rm -rf /srv/pillar
rm -rf /srv/reactor
cp -R /etc/homelabmanager/saltstack/salt /srv/salt
cp -R /etc/homelabmanager/saltstack/pillar /srv/pillar
cp -R /etc/homelabmanager/saltstack/reactor /srv/reactor

systemctl restart salt-master
