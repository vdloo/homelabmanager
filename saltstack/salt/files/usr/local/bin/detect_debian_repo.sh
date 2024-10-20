#!/usr/bin/bash
set -e

if timeout 1 bash -c "</dev/tcp/{{ pillar['debianrepo_static_ip'] }}/80"; then
    echo "deb [trusted=yes] http://{{  pillar['debianrepo_static_ip'] }} buster main" > /tmp/temp_apt_sources.list
    echo "deb [trusted=yes] http://{{  pillar['debianrepo_static_ip'] }} buster-updates main" >> /tmp/temp_apt_sources.list
    echo "deb [trusted=yes] http://{{  pillar['debianrepo_static_ip'] }} buster-backports main" >> /tmp/temp_apt_sources.list
    echo "deb [trusted=yes] http://{{  pillar['debianrepo_static_ip'] }} buster-security main" >> /tmp/temp_apt_sources.list
else
    echo "deb http://deb.debian.org/debian/ buster main" > /tmp/temp_apt_sources.list
    echo "deb http://deb.debian.org/debian/ buster-updates main" >> /tmp/temp_apt_sources.list
    echo "deb http://archive.debian.org/debian/ buster-backports main" >> /tmp/temp_apt_sources.list
    echo "deb http://security.debian.org/debian-security buster/updates main" >> /tmp/temp_apt_sources.list
fi

mv /tmp/temp_apt_sources.list /etc/apt/sources.list
