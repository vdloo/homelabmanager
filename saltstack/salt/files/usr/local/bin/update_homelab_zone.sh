#!/bin/bash
set -e
pdnsutil delete-zone homelab || /bin/true
pdnsutil create-zone homelab ns1.homelab
pdnsutil add-record homelab router A 192.168.1.1
