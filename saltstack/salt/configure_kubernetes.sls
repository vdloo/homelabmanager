#!jinja|yaml
---

install_sudo_package:
  pkg.installed:
    - pkgs:
        - sudo

write_configure_kubernetes_script:
  file.managed:
    - name: /usr/local/bin/configure_kubernetes.sh
    - source: salt://files/usr/local/bin/configure_kubernetes.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

configure_kubernetes:
  cmd.run:
    - name: /usr/local/bin/configure_kubernetes.sh >> /tmp/configure_kubernetes_log 2>&1 &
