#!jinja|yaml
---

install_ipv4_firewall_rules:
  file.managed:
    - name: /etc/iptables/iptables.rules
    - source: salt://files/etc/iptables/iptables.rules
    - user: root
    - group: root
    - mode: 644
    - template: jinja

install_ipv6_firewall_rules:
  file.managed:
    - name: /etc/iptables/ip6tables.rules
    - source: salt://files/etc/iptables/ip6tables.rules
    - user: root
    - group: root
    - mode: 644
    - template: jinja

install_ipv4_firewall_service:
  file.managed:
    - name: /usr/lib/systemd/system/iptables.service
    - source: salt://files/usr/lib/systemd/system/iptables.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - follow_symlinks: False

install_ipv6_firewall_service:
  file.managed:
    - name: /usr/lib/systemd/system/ip6tables.service
    - source: salt://files/usr/lib/systemd/system/ip6tables.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - follow_symlinks: False

daemon_reload_if_firewall_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/iptables.service
        - file: /usr/lib/systemd/system/ip6tables.service

start_and_enable_ipv4_firewall:
  service.running:
    - enable: true
    - name: iptables
    - watch:
        - file: /usr/lib/systemd/system/iptables.service

start_and_enable_ipv6_firewall:
  service.running:
    - enable: true
    - name: ip6tables
    - watch:
        - file: /usr/lib/systemd/system/ip6tables.service
