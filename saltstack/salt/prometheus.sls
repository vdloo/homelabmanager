include:
  - shellserver

allow_unprivileged_to_bind_privileged_ports_on_prometheus:
  sysctl.present:
    - name: net.ipv4.ip_unprivileged_port_start
    - value: 1

place_prometheus_config:
  file.managed:
{% if grains.os_family == 'Arch' %}
    - name: /etc/conf.d/prometheus
{% else %}
    - name: /etc/default/prometheus
{% endif %}
    - source: salt://files/etc/default/prometheus
    - user: root
    - group: root
    - mode: 644

install_prometheus_packages:
  pkg.installed:
    - pkgs:
        - prometheus

run_prometheus_service:
  service.running:
    - enable: true
    - name: prometheus
  require:
    - pkg: prometheus

install_update_prometheus_config_script:
  file.managed:
    - name: /usr/local/bin/update_prometheus_config.sh
    - source: salt://files/usr/local/bin/update_prometheus_config.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

periodically_update_prometheus_config:
  cron.present:
    - user: root
    - minute: '*/3'
    - name: /usr/local/bin/update_prometheus_config.sh
