#!jinja|yaml
---

include:
  - shellserver

install_clone_development_projects_script:
  file.managed:
    - name: /usr/local/bin/clone_development_projects.sh
    - source: salt://files/usr/local/bin/clone_development_projects.sh
    - user: root
    - group: root
    - mode: 755

clone_development_projects:
  cmd.run:
    - name: /usr/local/bin/clone_development_projects.sh > /tmp/clone_development_projects 2>&1 &
    - runas: {{ pillar['shellserver_unprivileged_user_name'] }}
