seconddisk_script_file:
  file.managed:
    - name: /usr/local/bin/seconddisk.sh
    - source: salt://files/usr/local/bin/seconddisk.sh
    - user: root
    - group: root
    - mode: 744

write_seconddisk_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/seconddisk.service
    - source: salt://files/usr/lib/systemd/system/seconddisk.service
    - user: root
    - group: root
    - mode: 644

daemon_reload_if_seconddisk_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/seconddisk.service

ensure_seconddisk_running:
  service.running:
    - enable: true
    - name: seconddisk
