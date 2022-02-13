include:
  - shellserver
  - saltmaster

clone_homelabmanager_repo:
  git.latest:
    - target: /etc/homelabmanager
    - branch: master
    - name: https://github.com/vdloo/homelabmanager.git

write_configure_homelab_vm_salt_master_script:
  file.managed:
    - name: /usr/local/bin/configure_homelab_vm_salt_master.sh
    - source: salt://files/usr/local/bin/configure_homelab_vm_salt_master.sh
    - user: root
    - group: root
    - mode: 755

configure_homelab_vm_salt_master_if_needed:
  cmd.run:
    - name: /usr/local/bin/configure_homelab_vm_salt_master.sh > /tmp/conifgure_homelab_vm_salt_master_log 2>&1 &
    - onchanges:
      - git: clone_homelabmanager_repo

enable_saltmaster_service:
  service.running:
    - enable: true
    - name: salt-master
