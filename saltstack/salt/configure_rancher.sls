#!jinja|yaml
---

write_configure_rancher_script:
  file.managed:
    - name: /usr/local/bin/configure_rancher.sh
    - source: salt://files/usr/local/bin/configure_rancher.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

configure_rancher:
  cmd.run:
    - name: /usr/local/bin/configure_rancher.sh >> /tmp/configure_rancher_log 2>&1 &
