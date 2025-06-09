#!/usr/bin/bash
set -e

AGENT_NUMBER=(233 110)
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
  sudo -i -u $UNPRIVILEGED_USER bash -c "cd code/projects/vibe-skeleton; python3 -m venv venv; . venv/bin/activate; pip install -r requirements/dev.txt; ./manage.py migrate"
  for num in "${AGENT_NUMBER[@]}"; do
    sudo -i -u $UNPRIVILEGED_USER bash -c "cp -R code/projects/vibe-skeleton code/projects/vibe-skeleton${num}"
    systemctl enable vibe-skeleton@${num}
    systemctl restart vibe-skeleton@${num}
  done
fi

