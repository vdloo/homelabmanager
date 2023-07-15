#!/usr/bin/bash
set -e

if ! test -d /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager; then
    echo "No checkout of homelabmanager in /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager yet!"
    exit 1
fi

rm -rf /srv/salt
rm -rf /srv/pillar
rm -rf /srv/reactor
cp -R /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager/saltstack/salt /srv/salt
cp -R /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager/saltstack/pillar /srv/pillar
cp -R /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager/saltstack/reactor /srv/reactor

# Give the homelabmanager admin another color if deployed with homelabmanager
sed -i 's/4d4d4d/5d4d4d/g' /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager/homelabmanager/templates/admin/base.html

systemctl restart salt-master
