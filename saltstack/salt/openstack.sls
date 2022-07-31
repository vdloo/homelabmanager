include:
  - shellserver

install_openstack_packages:
  pkg.installed:
    - pkgs:
        - bridge-utils

install_stack_user:
  user.present:
    - name: stack
{% if grains.os_family == 'Arch' %}
    - password: {{ pillar['shellserver_unprivileged_user_archlinux_password_hash'] }}
{% else %}
    - password: {{ pillar['shellserver_unprivileged_user_debian_password_hash'] }}
{% endif %}
    - createhome: true
    - home: /opt/stack
    - shell: /bin/bash

ensure_stack_ssh_dir:
  file.directory:
    - name: /opt/stack/.ssh
    - user: stack
    - group: stack
    - mode: 700
    - makedirs: true

ensure_global_key_is_on_disk_for_stack_user:
  file.managed:
    - name: /opt/stack/.ssh/id_rsa
    - contents_pillar: private_key
    - user: stack
    - group: stack
    - mode: 600

ensure_global_public_key_is_on_disk_for_stack_user:
  file.managed:
    - name: /opt/stack/.ssh/id_rsa.pub
    - contents_pillar: public_key
    - user: stack
    - group: stack
    - mode: 644

create_devstack_data_dir:
  file.directory:
    - name: /mnt/disk/devstack
    - user: stack
    - group: stack
    - mode: 755
    - makedirs: true

create_symlink_to_stack_data_dir:
  file.symlink:
    - name: /opt/stack/data
    - target: /mnt/disk/devstack
    - force: true

write_configure_openstack_script:
  file.managed:
    - name: /usr/local/bin/configure_openstack.sh
    - source: salt://files/usr/local/bin/configure_openstack.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

configure_openstack_if_needed:
  cmd.run:
    - name: /usr/local/bin/configure_openstack.sh >> /tmp/configure_openstack_log 2>&1 &
    - runas: stack
    - cwd: /opt/stack
  require:
    - pkg: bridge-utils
