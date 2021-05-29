#!/bin/bash
set -e
CHECKSUM_BEFORE=$(md5sum "/srv/salt/files/usr/local/bin/update_homelab_zone.sh")
ACTIVE_ROLES=$(salt '*' grains.item role --out=json | grep role | cut -d '"' -f4 | sort | uniq)
if [ -z "$ACTIVE_ROLES" ]; then
    echo "No active roles right now, that's OK!"
    exit 0
fi
cat <<EOF > /tmp/update_homelab_zone.sh
#!/bin/bash
set -e
pdnsutil delete-zone homelab || /bin/true
pdnsutil create-zone homelab ns1.homelab
pdnsutil add-record homelab router A 192.168.1.1
EOF

if [ -f /root/additional_zone_commands ]; then
    cat /root/additional_zone_commands >> /tmp/update_homelab_zone.sh
fi

for ACTIVE_ROLE in $ACTIVE_ROLES; do
    IP_ADDRESSES=$(salt -G "role:$ACTIVE_ROLE" grains.item ipv4 --out=json | grep 192.168.1 | cut -d '"' -f2)
    for IP_ADDRESS in $IP_ADDRESSES; do
        echo "pdnsutil add-record homelab $ACTIVE_ROLE A $IP_ADDRESS" >> /tmp/update_homelab_zone.sh
    done
done
cp /tmp/update_homelab_zone.sh /srv/salt/files/usr/local/bin/update_homelab_zone.sh
CHECKSUM_AFTER=$(md5sum "/srv/salt/files/usr/local/bin/update_homelab_zone.sh")
if [ "$CHECKSUM_BEFORE" != "$CHECKSUM_AFTER" ] ; then
    salt -G "role:powerdns" state.apply
fi
