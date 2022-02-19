#!/usr/bin/bash
set -e

# Create a simple 'fifo in' at /tmp/homelabirc/192.168.x.x/#homelabstatus/in
# Anything piped to there will be messaged in the #homelabstatus IRC channel
# See https://tools.suckless.org/ii/bots/ for how this works.

while true; do
    ii -i /tmp/homelabirc -s {{ pillar['irc_static_ip'] }} -n "$(hostname)-log" -f "$(hostname)-log" &
    iipid="$!"
    sleep 10
    printf "/j %s\n" "#homelabstatus" > /tmp/homelabirc/{{ pillar['irc_static_ip'] }}/in
    wait "$iipid"
done
