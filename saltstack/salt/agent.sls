#!jinja|yaml
---

include:
  - devenv

install_agent_packages:
  pkg.installed:
    - pkgs:
        - lighttpd

{% if grains.os_family == 'Debian' %}
install_agent_packages_for_debian:
  pkg.installed:
    - pkgs:
      - gitweb
{% endif %}

write_aider_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/aider.service
    - source: salt://files/usr/lib/systemd/system/aider.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja

daemon_reload_if_aider_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/aider.service

ensure_aider_dir:
  file.directory:
    - name: /etc/aider
    - user: root
    - group: root
    - mode: 755
    - makedirs: true

write_install_aider_script:
  file.managed:
    - name: /usr/local/bin/install_aider.sh
    - source: salt://files/usr/local/bin/install_aider.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - require:
      - file: /etc/aider

install_aider_if_needed:
  cmd.run:
    - name: /usr/local/bin/install_aider.sh > /tmp/install_aider_log 2>&1 &
