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
