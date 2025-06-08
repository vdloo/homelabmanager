#!/usr/bin/bash
set -e

if [ -d ~/code/projects/homelabmanager ]; then
    echo "Development projects already set up, skipping"
    exit 0
fi

mkdir -p ~/code/projects 
cd ~/code/projects 
git clone https://github.com/vdloo/homelabmanager &
git clone https://github.com/vdloo/dotfiles &
git clone https://github.com/vdloo/machine-check &
git clone https://github.com/vdloo/detect-os-release &
git clone https://github.com/vdloo/vibe-skeleton &
