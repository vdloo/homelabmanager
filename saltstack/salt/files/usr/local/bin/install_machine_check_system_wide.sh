#!/usr/bin/bash
set -e
cd /etc/machine-check
rm -rf /etc/machine-check/out
raco pkg install --deps search-auto
make build
cp /etc/machine-check/out/machine-check /usr/bin/
