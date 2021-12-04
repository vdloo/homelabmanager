#!/usr/bin/bash
figlet -f slant $(grep role /etc/salt/grains | cut -d' ' -f2) > /tmp/temp_motd
neofetch --disable packages --color_blocks off >> /tmp/temp_motd
mv -f /tmp/temp_motd /etc/motd
