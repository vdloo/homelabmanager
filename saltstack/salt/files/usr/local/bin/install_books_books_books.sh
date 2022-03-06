#!/usr/bin/bash
set -e

cd /etc/booksbooksbooks
if test -d venv; then
  echo "Booksbooksbooks venv already exists"
else
  echo "Creating new booksbooksbooks venv"
  python3 -m venv venv
  . venv/bin/activate
  pip3 install wheel
  pip3 install -r requirements/dev.txt
  ./manage.py migrate
  systemctl enable booksbooksbooks
  systemctl restart booksbooksbooks
  sed -i 's/localhost:8001/localhost:80/g' importer/main.py
  mkdir -p /mnt/storage/booksbooksbooks
  python importer/main.py /mnt/storage/booksbooksbooks
fi
