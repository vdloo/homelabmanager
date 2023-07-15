include:
  - shellserver
  - saltmaster

clone_homelabmanager_repo:
  git.latest:
    - target: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager
    - branch: master
    - name: https://github.com/vdloo/homelabmanager.git
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}

write_configure_homelab_vm_salt_master_script:
  file.managed:
    - name: /usr/local/bin/configure_homelab_vm_salt_master.sh
    - source: salt://files/usr/local/bin/configure_homelab_vm_salt_master.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

configure_homelab_vm_salt_master_if_needed:
  cmd.run:
    - name: /usr/local/bin/configure_homelab_vm_salt_master.sh > /tmp/configure_homelab_vm_salt_master_log 2>&1 &
    - onchanges:
      - git: clone_homelabmanager_repo

{%- if not salt['file.directory_exists' ]("/home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager/venv") %}
ensure_homelabmanager_venv:
  cmd.run:
    - name: python3 -m venv venv && venv/bin/pip install -r requirements/dev.txt
    - runas: {{ pillar['shellserver_unprivileged_user_name'] }}
    - cwd: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager
{%- endif %}

{%- if not salt['file.file_exists' ]("/home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager/db.sqlite3") %}
ensure_homelabmanager_db:
  cmd.run:
    - env:
      - PYTHONPATH: {{ pillar['shellserver_unprivileged_user_name'] }}
      - DJANGO_SETTINGS_MODULE: homelabmanager.settings
    - name: venv/bin/python manage.py migrate
    - runas: {{ pillar['shellserver_unprivileged_user_name'] }}
    - cwd: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/homelabmanager
{%- endif %}

enable_saltmaster_service:
  service.running:
    - enable: true
    - name: salt-master

write_homelabmanager_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/homelabmanager.service
    - source: salt://files/usr/lib/systemd/system/homelabmanager.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja

daemon_reload_if_homelabmanager_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/homelabmanager.service

ensure_homelabmanager_running:
  service.running:
    - enable: true
    - name: homelabmanager
