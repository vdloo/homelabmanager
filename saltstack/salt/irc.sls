include:
  - shellserver

install_irc_server_packages:
  pkg.installed:
    - pkgs:
        - inspircd

ensure_irc_motd:
  file.managed:
    - name: /etc/inspircd/inspircd.motd
    - source: salt://files/etc/inspircd/inspircd.motd
    - user: root
    - group: root
    - mode: 0644

ensure_perm_channel_in_config:
  cmd.run:
    - name: grep -q "#homelabstatus" /etc/inspircd/inspircd.conf || /usr/bin/echo -e '<module name="m_permchannels.so">\n<permchannels channel="#homelabstatus" modes="nt" topic="Homelab status">' >> /etc/inspircd/inspircd.conf

truncate_inspircd_rules_file:
  cmd.run:
    - name: truncate -s 0 /etc/inspircd/inspircd.rules

bind_inspircd_on_all_interfaces:
  cmd.run:
    - name: sed -i 's/<bind address="127.0.0.1"/<bind address="0.0.0.0"/g' /etc/inspircd/inspircd.conf

run_inspircd_service:
  service.running:
    - enable: true
    - name: inspircd
    - watch:
        - file: /etc/inspircd/inspircd.motd
