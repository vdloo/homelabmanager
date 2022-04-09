#!jinja|yaml
---

include:
  - storage

install_ipv4_firewall_rules:
  file.managed:
    - name: /etc/iptables/iptables.rules
    - source: salt://files/etc/iptables/iptables.rules
    - user: root
    - group: root
    - mode: 644
    - template: jinja

install_ipv6_firewall_rules:
  file.managed:
    - name: /etc/iptables/ip6tables.rules
    - source: salt://files/etc/iptables/ip6tables.rules
    - user: root
    - group: root
    - mode: 644
    - template: jinja

install_ipv4_firewall_service:
  file.managed:
    - name: /usr/lib/systemd/system/iptables.service
    - source: salt://files/usr/lib/systemd/system/iptables.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - follow_symlinks: False

install_ipv6_firewall_service:
  file.managed:
    - name: /usr/lib/systemd/system/ip6tables.service
    - source: salt://files/usr/lib/systemd/system/ip6tables.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - follow_symlinks: False

daemon_reload_if_firewall_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/iptables.service
        - file: /usr/lib/systemd/system/ip6tables.service

start_and_enable_ipv4_firewall:
  service.running:
    - enable: true
    - name: iptables
    - watch:
        - file: /usr/lib/systemd/system/iptables.service

start_and_enable_ipv6_firewall:
  service.running:
    - enable: true
    - name: ip6tables
    - watch:
        - file: /usr/lib/systemd/system/ip6tables.service

{% if grains.os_family == 'Arch' %}
ensure_cron_running_for_archlinux:
  service.running:
    - enable: true
    - name: cronie
{% else %}
ensure_cron_running_for_debian:
  service.running:
    - enable: true
    - name: cron
{% endif %}

{% if grains.oscodename == 'buster' %}
run_detect_debian_repo_periodically:
  cron.present:
    - user: root
    - minute: '*'
    - name: /usr/local/bin/detect_debian_repo.sh
{% endif %}

{% if grains.oscodename == 'buster' %}
write_racket_apt_preference_for_backport:
  file.managed:
    - name: /etc/apt/preferences.d/buster_backports
    - source: salt://files/etc/apt/preferences.d/buster_backports
    - user: root
    - group: root
    - mode: 644
{% endif %}

place_prometheus_node_exporter_config:
  file.managed:
{% if grains.os_family == 'Arch' %}
  - name: /etc/conf.d/prometheus-node-exporter
{% else %}
  - name: /etc/default/prometheus-node-exporter
{% endif %}
  - source: salt://files/etc/default/prometheus-node-exporter
  - user: root
  - group: root
  - mode: 644
  - template: jinja

install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - consul
      - figlet
      - git
      - irssi
      - jq
      - neofetch
      - nmap
      - prometheus-node-exporter
      - rsync
      - screen
      - wget
    - refresh: true

{% if grains.os_family == 'Arch' %}
install_shellserver_packages_for_archlinux:
  pkg.installed:
    - pkgs:
      - go
      - python-mysqlclient
      - python-pip
      - python-sqlparse
      - python-virtualenv
      - python-wheel
      - vim

      # This is base-devel Salt doesn't work well with Archlinux package groups
      - autoconf
      - automake
      - binutils
      - bison
      - fakeroot
      - file
      - findutils
      - flex
      - gawk
      - gcc
      - gettext
      - grep
      - groff
      - gzip
      - libtool
      - m4
      - make
      - pacman
      - patch
      - pkgconf
      - sed
      - sudo
      - texinfo
      - which
{% else %}
install_shellserver_packages_for_debian:
  pkg.installed:
    - pkgs:
      - autoconf
      - automake
      - build-essential
      - crudini
      - golang
      - ii
      - m4
      - python3-mysqldb
      - python3-pip
      - python3-sqlparse
      - python3-venv
      - python3-wheel
      - vim-nox
{% endif %}

write_update_motd_script:
  file.managed:
    - name: /usr/local/bin/update_motd.sh
    - source: salt://files/usr/local/bin/update_motd.sh
    - user: root
    - group: root
    - mode: 755

update_motd_periodically:
  cron.present:
    - user: root
    - minute: '*'
    - name: /usr/local/bin/update_motd.sh

install_use_powerdns_if_up_script:
  file.managed:
    - name: /usr/local/bin/use_powerdns_if_up.sh
    - source: salt://files/usr/local/bin/use_powerdns_if_up.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

run_use_powerdns_if_up_periodically:
  cron.present:
    - user: root
    - minute: '*'
    - name: /usr/local/bin/use_powerdns_if_up.sh

install_use_prometheus_if_up_script:
  file.managed:
    - name: /usr/local/bin/use_prometheus_if_up.sh
    - source: salt://files/usr/local/bin/use_prometheus_if_up.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

run_use_prometheus_if_up_periodically:
  cron.present:
    - user: root
    - minute: '*'
    - name: /usr/local/bin/use_prometheus_if_up.sh

clone_yggdrasil_repo:
  git.latest:
    - target: /etc/yggdrasil-go
    - branch: cli-tool-to-convert-pubkey-to-ip
    - name: https://github.com/vdloo/yggdrasil-go
    - force_reset: true

write_install_yggdrasil_system_wide_script:
  file.managed:
    - name: /usr/local/bin/install_yggdrasil_system_wide.sh
    - source: salt://files/usr/local/bin/install_yggdrasil_system_wide.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

install_yggdrasil_system_wide_if_needed:
  cmd.run:
    - name: /usr/local/bin/install_yggdrasil_system_wide.sh > /tmp/install_yggdrasil_log 2>&1 &
    - onchanges:
      - git: clone_yggdrasil_repo

write_locale_file:
  file.managed:
    - name: /etc/default/locale
    - source: salt://files/etc/default/locale
    - user: root
    - group: root
    - mode: 644

write_locale_gen_file:
  file.managed:
    - name: /etc/locale.gen
    - source: salt://files/etc/locale.gen
    - user: root
    - group: root
    - mode: 644

generate_locales:
  cmd.run:
    - name: locale-gen
    - onchanges:
      - file: write_locale_gen_file

configure_root_user:
  user.present:
    - name: root
    - fullname: root
{% if grains.os_family == 'Arch' %}
    - password: {{ pillar['shellserver_unprivileged_user_archlinux_password_hash'] }}
{% else %}
    - password: {{ pillar['shellserver_unprivileged_user_debian_password_hash'] }}
{% endif %}
    - shell: /bin/bash

install_unprivileged_user:
  user.present:
    - name: {{ pillar['shellserver_unprivileged_user_name'] }}
    - fullname: {{ pillar['shellserver_unprivileged_user_full_name'] }}
{% if grains.os_family == 'Arch' %}
    - password: {{ pillar['shellserver_unprivileged_user_archlinux_password_hash'] }}
{% else %}
    - password: {{ pillar['shellserver_unprivileged_user_debian_password_hash'] }}
{% endif %}
    - createhome: true
    - shell: /bin/bash

passwordless_sudo_for_unprivileged_user:
  file.managed:
    - name: /etc/sudoers.d/nopassword
    - source: salt://files/etc/sudoers.d/nopassword
    - user: root
    - group: root
    - mode: 0440
    - template: jinja

clone_dotfiles_repo:
  git.latest:
    - target: /etc/dotfiles
    - branch: master
    - name: https://github.com/vdloo/dotfiles

symlink_bashrc_to_root_user_home:
  file.symlink:
    - name: /root/.bashrc
    - target: /etc/dotfiles/.bashrc
    - force: true

symlink_bashrc_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.bashrc
    - target: /etc/dotfiles/.bashrc
    - force: true

symlink_profile_to_root_user_home:
  file.symlink:
    - name: /root/.profile
    - target: /etc/dotfiles/.profile
    - force: true

symlink_profile_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.profile
    - target: /etc/dotfiles/.profile
    - force: true

create_root_ssh_config_d_directory:
  file.directory:
    - name: /root/.ssh/config.d
    - user: root
    - group: root
    - mode: 0700
    - makedirs: true

create_unprivileged_user_ssh_config_d_directory:
  file.directory:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.ssh/config.d
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}
    - group: {{ pillar['shellserver_unprivileged_user_name'] }}
    - mode: 0700
    - makedirs: true

symlink_ssh_config_to_root_user:
  file.symlink:
    - name: /root/.ssh/config
    - target: /etc/dotfiles/.ssh/config
    - force: true

symlink_ssh_config_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.ssh/config
    - target: /etc/dotfiles/.ssh/config
    - force: true

create_htop_config_directory_for_root_user:
  file.directory:
    - name: /root/.config/htop/
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}
    - group: {{ pillar['shellserver_unprivileged_user_name'] }}
    - mode: 0700
    - makedirs: true

create_htop_config_directory_for_unprivileged_user:
  file.directory:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.config/htop/
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}
    - group: {{ pillar['shellserver_unprivileged_user_name'] }}
    - mode: 0700
    - makedirs: true

clone_vundle_repo:
  git.latest:
    - target: /etc/vundle
    - branch: master
    - name: https://github.com/VundleVim/Vundle.vim

install_configure_vim_script:
  file.managed:
    - name: /usr/local/bin/configure_vim.sh
    - source: salt://files/usr/local/bin/configure_vim.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

configure_vim_if_needed:
  cmd.run:
    - name: /usr/local/bin/configure_vim.sh > /tmp/configure_vim_log 2>&1 &
    - onchanges:
      - file: /usr/local/bin/configure_vim.sh
      - git: clone_vundle_repo

symlink_vimrc_to_root_user_home:
  file.symlink:
    - name: /root/.vimrc
    - target: /etc/dotfiles/.vimrc
    - force: true

symlink_vimrc_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.vimrc
    - target: /etc/dotfiles/.vimrc
    - force: true

copy_initial_htop_config_for_root_user:
  cmd.run:
    - name: cp /etc/dotfiles/.config/htop/htoprc /root/.config/htop/htoprc

copy_initial_htop_config_for_unprivileged_user_user:
  cmd.run:
    - name: cp --no-clobber /etc/dotfiles/.config/htop/htoprc /home/{{  pillar['shellserver_unprivileged_user_name'] }}/.config/htop/htoprc

create_root_irssi_config_directory:
  file.directory:
    - name: /root/.irssi
    - user: root
    - group: root
    - mode: 0700

install_root_irssi_config_file:
  file.managed:
    - name: /root/.irssi/config
    - source: salt://files/root/.irssi/config
    - user: root
    - group: root
    - mode: 0640
    - template: jinja

{% if grains.ipv6_overlay %}
write_yggdrasil_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/yggdrasil.service
    - source: salt://files/usr/lib/systemd/system/yggdrasil.service
    - user: root
    - group: root
    - mode: 644

daemon_reload_if_yggdrasil_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/yggdrasil.service

ensure_yggdrasil_running:
  service.running:
    - enable: true
    - name: yggdrasil
{% endif %}

{% if grains.os_family == 'Arch' %}
create_consul_config_directory:
  file.directory:
    - name: /opt/consul
    - user: consul
    - group: consul
    - mode: 0755
{% endif %}

install_uuid_from_string_script:
  file.managed:
    - name: /usr/local/bin/uuid_from_string.py
    - source: salt://files/usr/local/bin/uuid_from_string.py
    - user: root
    - group: root
    - mode: 755

install_configure_consul_script:
  file.managed:
    - name: /usr/local/bin/configure_consul.sh
    - source: salt://files/usr/local/bin/configure_consul.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

configure_consul_if_needed:
  cmd.run:
    - name: /usr/local/bin/configure_consul.sh > /tmp/configure_consul_log 2>&1 &
    - onchanges:
      - file: /usr/local/bin/configure_consul.sh

start_and_enable_consul:
  service.running:
    - enable: true
    - name: consul
    - watch:
        - file: /usr/local/bin/configure_consul.sh

install_machine_check_packages:
  pkg.installed:
    - pkgs:
        - racket

ensure_machine_check_tests_dir:
  file.directory:
    - name: /srv/machine-check
    - user: root
    - group: root
    - mode: 755

ensure_machine_check_tests:
  file.recurse:
    - source: salt://files/srv/machine-check
    - name: /srv/machine-check
    - file_mode: keep
    - template: jinja

clone_machine_check_repo:
  git.latest:
    - target: /etc/machine-check
    - branch: master
    - name: https://github.com/vdloo/machine-check

write_install_machine_check_system_wide_script:
  file.managed:
    - name: /usr/local/bin/install_machine_check_system_wide.sh
    - source: salt://files/usr/local/bin/install_machine_check_system_wide.sh
    - user: root
    - group: root
    - mode: 755

install_machine_check_system_wide_if_needed:
  cmd.run:
    - name: /usr/local/bin/install_machine_check_system_wide.sh > /tmp/install_machine_check_log 2>&1 &
    - onchanges:
        - git: clone_machine_check_repo
        - file: /srv/machine-check

install_write_applied_states_script:
  file.managed:
    - name: /usr/local/bin/write_applied_states.sh
    - source: salt://files/usr/local/bin/write_applied_states.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

write_applied_states:
  cmd.run:
    - name: /usr/local/bin/write_applied_states.sh > /tmp/write_applied_states_log 2>&1 &
