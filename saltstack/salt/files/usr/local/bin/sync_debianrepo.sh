#!/usr/bin/bash
set -e

echo "Running reprepro to sync the Buster repo from upstream"
/usr/bin/reprepro -b /srv/reprepro update
