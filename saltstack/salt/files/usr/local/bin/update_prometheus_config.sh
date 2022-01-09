#!/usr/bin/bash
set -e

OLD_HASH=$(md5sum /etc/prometheus/prometheus.yml)
cat << 'EOF' > /tmp/generated_prometheus_config.yml
global:
  scrape_interval:     15s # Set the scrape interval to every 15 seconds. Default is every 1 minute.
  evaluation_interval: 15s # Evaluate rules every 15 seconds. The default is every 1 minute.
  external_labels:
      monitor: 'example'

# Alertmanager configuration
alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:9093']

scrape_configs:
  - job_name: 'prometheus'
    # Override the global default and scrape targets from this job every 5 seconds.
    scrape_interval: 5s
    scrape_timeout: 5s

    # metrics_path defaults to '/metrics'
    # scheme defaults to 'http'.
    static_configs:
      - targets: ['{{ pillar['prometheus_static_ip'] }}:80']

  - job_name: node
    static_configs:
      - targets:
        - '{{ pillar['prometheus_static_ip'] }}:19100'
EOF

# Scan the network for new hosts with 19100 open (the homelab prometheus-node-exporter port)
nmap --open -sS -p 19100 192.168.1.0/24 -oG - | grep 19100/open/tcp | awk '{print$2}' \
  | xargs -I {} echo "        - '{}:19100'" >> /tmp/generated_prometheus_config.yml

NEW_HASH=$(md5sum /tmp/generated_prometheus_config.yml)
if [ "$OLD_HASH" != "$NEW_HASH" ]; then
  cp /tmp/generated_prometheus_config.yml /etc/prometheus/prometheus.yml
  systemctl reload prometheus
fi
