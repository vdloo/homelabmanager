#!/usr/bin/bash
set -e

UNPRIVILEGED_USER={{ pillar['shellserver_unprivileged_user_name'] }}
cd /etc/llama.cpp
if test -d build; then
  echo "Build dir already exists"
else
  echo "Setting up llama.cpp"
  chown -R $UNPRIVILEGED_USER:$UNPRIVILEGED_USER /etc/llama.cpp
  sudo -i -u $UNPRIVILEGED_USER bash -c "cd /etc/llama.cpp; cmake -B build; cmake --build build --config Release -j $(nproc)"

  if test -d /mnt/storage/models; then
      echo "Starting llama.cpp service"
      systemctl enable llama_cpp
      systemctl restart llama_cpp
  else
      echo "Not connected to storage, not starting llama.cpp. Won't have access to models."
  fi

fi
