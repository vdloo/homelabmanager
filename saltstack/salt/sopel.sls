{% if grains.os_family != 'Arch' %}
install_sopel_irc_bot:
  pip.installed:
    - name: sopel
    - bin_env: '/usr/bin/pip3'

create_unprivileged_user_sopel_config_directory:
  file.directory:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.sopel
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}
    - group: {{ pillar['shellserver_unprivileged_user_name'] }}
    - mode: 0755

install_unprivileged_user_sopel_config:
  file.managed:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.sopel/default.cfg
    - source: salt://files/home/unprivileged_user/.sopel/default.cfg
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}
    - group: {{ pillar['shellserver_unprivileged_user_name'] }}
    - mode: 0640
    - template: jinja

write_sopel_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/sopel.service
    - source: salt://files/usr/lib/systemd/system/sopel.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja

daemon_reload_if_sopel_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/sopel.service

ensure_sopel_running:
  service.running:
    - enable: true
    - name: sopel

install_configure_ii_irc_fifo:
  file.managed:
    - name: /usr/local/bin/configure_ii_irc_fifo.sh
    - source: salt://files/usr/local/bin/configure_ii_irc_fifo.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

write_ii_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/ii.service
    - source: salt://files/usr/lib/systemd/system/ii.service
    - user: root
    - group: root
    - mode: 644

daemon_reload_if_ii_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/ii.service

ensure_ii_running:
  service.running:
    - enable: true
    - name: ii
{% endif %}
