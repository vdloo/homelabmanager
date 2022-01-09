include:
  - shellserver

allow_unprivileged_to_bind_privileged_ports:
  sysctl.present:
    - name: net.ipv4.ip_unprivileged_port_start
    - value: 1

configure_prometheus_defaults:
  file.managed:
    - name: /etc/default/prometheus
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
