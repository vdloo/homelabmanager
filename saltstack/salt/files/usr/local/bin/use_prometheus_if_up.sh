#!/usr/bin/bash
set -e
if timeout 1 bash -c "</dev/tcp/{{ pillar['prometheus_static_ip'] }}/80"; then
  if ! systemctl is-active --quiet prometheus-node-exporter; then
    systemctl restart prometheus-node-exporter
  fi
else
    systemctl stop prometheus-node-exporter
fi
