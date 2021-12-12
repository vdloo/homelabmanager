#!jinja|yaml
---

include:
  - storage

install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - figlet
      - git
      - jq
      - neofetch
      - nmap
      - racket
      - screen
      - wget

{% if grains.os_family == 'Arch' %}
install_shellserver_packages_for_archlinux:
  pkg.installed:
    - pkgs:
      - cronie
      - python-mysqlclient
      - python-pip
      - python-sqlparse
      - python-virtualenv
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
      - cron
      - automake
      - autoconf
      - m4
      - build-essential
      - python3-mysqldb
      - python3-pip
      - python3-sqlparse
      - python3-venv
      - vim-nox
{% endif %}

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

clone_machine_check_repo:
  git.latest:
    - target: /etc/machine-check
    - branch: master
    - name: https://github.com/vdloo/machine-check

install_machine_check_system_wide:
  cmd.run:
    - name: bash -c 'rm -rf /etc/machine-check/out; raco pkg install --deps search-auto; make build; cp /etc/machine-check/out/machine-check /usr/bin/'
    - cwd: /etc/machine-check
    - onchanges:
      - git: clone_machine_check_repo
      - file: /srv/machine-check

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
    - name: cp --no-clobber /etc/dotfiles/.config/htop/htoprc /root/.config/htop/htoprc

copy_initial_htop_config_for_unprivileged_user_user:
  cmd.run:
    - name: cp --no-clobber /etc/dotfiles/.config/htop/htoprc /home/{{  pillar['shellserver_unprivileged_user_name'] }}/.config/htop/htoprc

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
