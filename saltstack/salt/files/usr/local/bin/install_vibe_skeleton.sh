#!/usr/bin/bash
set -e

UNPRIVILEGED_USER={{ pillar['shellserver_unprivileged_user_name'] }}
if ! id "$UNPRIVILEGED_USER" &>/dev/null; then
    echo "No such user '$UNPRIVILEGED_USER'"
    exit 1
fi

cd /home/${UNPRIVILEGED_USER}/code/projects/vibe-skeleton
if test -d venv; then
  echo "vibe-skeleton venv already exists"
else
  echo "Installing vibe-skeleton in venv"
  sudo -i -u $UNPRIVILEGED_USER bash -c 'cd code/projects/vibe-skeleton; python3 -m venv venv; . venv/bin/activate; pip install -r requirements/dev.txt; ./manage.py migrate'
  systemctl enable vibe-skeleton
  systemctl restart vibe-skeleton
fi
