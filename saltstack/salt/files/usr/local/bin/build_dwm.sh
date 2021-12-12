#!/usr/bin/bash
set -e

rm -rf /tmp/dwm_build_area
cp -R /etc/dwm /tmp/dwm_build_area
cd /tmp/dwm_build_area

# Apply fibonacci patch
wget -o /dev/null https://dwm.suckless.org/patches/fibonacci/dwm-fibonacci-6.2.diff -O fibonacci.diff
/usr/bin/patch < fibonacci.diff -f

# Apply gaplessgrid patch
wget -o /dev/null https://dwm.suckless.org/patches/gaplessgrid/dwm-gaplessgrid-6.1.diff -O gapless_grid.diff
/usr/bin/patch < gapless_grid.diff -f

cp /etc/dotfiles/code/configs/dwm/arch-config.h config.h

make install
