#!/usr/bin/bash
set -e

UNPRIVILEGED_USER={{ pillar['shellserver_unprivileged_user_name'] }}
if ! id "$UNPRIVILEGED_USER" &>/dev/null; then
    echo "No such user '$UNPRIVILEGED_USER'"
    exit 1
fi

if test -e /home/$UNPRIVILEGED_USER/.opencode/bin/opencode; then
    echo "Opencode already installed. Doing nothing"
    exit 0
fi

sudo -i -u $UNPRIVILEGED_USER /bin/bash -c 'curl -fsSL https://opencode.ai/install | bash'
mkdir -p /home/$UNPRIVILEGED_USER/.config/opencode
cat << 'EOF' > /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.config/opencode/opencode.json
{
  "$schema": "https://opencode.ai/config.json",
  "disabled_providers": ["opencode"],
  "theme": "lucent-orng",
  "provider": {
    "gpu": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "gpu llama-server (local)",
      "options": {
        "baseURL": "http://192.168.1.233:8080/v1"
      },
      "models": {
        "local-model": {
          "name": "gpu (local)",
          "limit": {
            "context": 128000,
            "output": 65536
          }
        }
      }
    },
    "cpu": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "cpu llama-server (local)",
      "options": {
        "baseURL": "http://192.168.1.235:8080/v1"
      },
      "models": {
        "local-model": {
          "name": "cpu (local)",
          "limit": {
            "context": 128000,
            "output": 65536
          }
        }
      }
    }
  }
}
EOF
chown -R $UNPRIVILEGED_USER:$UNPRIVILEGED_USER /home/$UNPRIVILEGED_USER/.config/opencode
if ! grep -q 'opencode' /home/$UNPRIVILEGED_USER/.bashrc-local; then
    echo 'export PATH=/home/{{ pillar['shellserver_unprivileged_user_name'] }}/.opencode/bin:$PATH' >> /home/$UNPRIVILEGED_USER/.bashrc-local
fi
