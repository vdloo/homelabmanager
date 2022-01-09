include:
  - shellserver

allow_unprivileged_to_bind_privileged_ports_on_grafana:
  sysctl.present:
    - name: net.ipv4.ip_unprivileged_port_start
    - value: 1

symlink_grafana_state_from_storage:
  file.symlink:
    - name: /var/lib/grafana
    - target: /mnt/storage/grafana
    - force: True

write_grafana_homelab_settings_configuration_file:
  file.managed:
    - name: /etc/grafana/homelab_settings.ini
    - source: salt://files/etc/grafana/homelab_settings.ini
    - user: root
    - group: root
    - mode: 644

install_grafana_debian_repo:
  pkgrepo.managed:
    - name: "deb https://packages.grafana.com/oss/deb stable main"
    - dist: stable
    - file: /etc/apt/sources.list.d/grafana.list
    - human_name: "Grafana repo"
    - key_url: https://packages.grafana.com/gpg.key
    - refresh: true

install_grafana_packages:
  pkg.installed:
    - pkgs:
        - grafana
  require:
    - pkgrepo: "deb https://packages.grafana.com/oss/deb stable main"

configure_grafana_settings:
  cmd.run:
    - name: cat /etc/grafana/homelabe_settings.ini | crudini --merge /etc/grafana/grafana.ini
  require:
    - pkg: grafana
    - file: /etc/grafana/noauth.ini

run_grafana_service:
  service.running:
    - enable: true
    - name: grafana-server
  require:
    - pkg: grafana

restart_grafana_to_configure_disabled_auth:
  cmd.run:
    - name: systemctl restart grafana-server
  require:
    - pkg: grafana
    - service: grafana-server
