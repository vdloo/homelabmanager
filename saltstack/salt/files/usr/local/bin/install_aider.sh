#!/usr/bin/bash
set -e

UNPRIVILEGED_USER={{ pillar['shellserver_unprivileged_user_name'] }}
if ! id "$UNPRIVILEGED_USER" &>/dev/null; then
    echo "No such user '$UNPRIVILEGED_USER'"
    exit 1
fi
if ! grep -q 'alias aider' /home/$UNPRIVILEGED_USER/.bashrc-local; then
    echo "alias aider='/etc/aider/venv/bin/aider --openai-api-base http://192.168.1.233:8080 --openai-api-key dummy --model openai/localmodel --no-show-model-warnings --yes --analytics-disable --no-show-model-warnings --no-check-model-accepts-settings '" >> /home/$UNPRIVILEGED_USER/.bashrc-local
fi
# Just to make sure we're using a locally hosted model
if ! grep -q openai; then
    echo "127.0.0.1     api.openai.com" >> /etc/hosts
    echo "127.0.0.1     platform.openai.com" >> /etc/hosts
fi

cd /etc/aider
if test -d venv; then
  echo "aider venv already exists"
else
  echo "Creating new aider venv"
  python3 -m venv venv
  . venv/bin/activate
  pip3 install -U --upgrade-strategy only-if-needed aider-chat[browser]
  systemctl enable aider
  systemctl restart aider
fi
