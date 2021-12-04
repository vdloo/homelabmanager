#!jinja|yaml
---

include:
  - storage

install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - git
      - jq
      - nmap
      - racket
      - screen
      - neofetch
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
    - name: bash -c 'raco pkg install --deps search-auto; make build; cp /etc/machine-check/out/machine-check /usr/bin/'
    - cwd: /etc/machine-check
    - onchanges:
      - git: clone_machine_check_repo

install_unprivileged_user:
  user.present:
    - name: {{ pillar['shellserver_unprivileged_user_name'] }}
    - fullname: {{ pillar['shellserver_unprivileged_user_full_name'] }}
    - password: {{ pillar['shellserver_unprivileged_user_password_hash'] }}
    - createhome: true
    - shell: /bin/bash

write_applied_states:
  cmd.run:
    - name: salt-call state.show_states concurrent=true --out json | jq -r '.local | .[]' > /srv/applied_states
