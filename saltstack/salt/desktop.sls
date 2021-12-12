include:
  - shellserver

install_desktop_packages:
  pkg.installed:
    - pkgs:
        - chromium
        - cmatrix
        - feh
        - terminator

{% if grains.os_family == 'Arch' %}
install_desktop_packages_for_archlinux:
  pkg.installed:
    - pkgs:
        - dmenu
        - libx11
        - libxft
        - libxinerama
        - xorg-server
        - xorg-xinit
        - xorg-xrandr
        - xorg-xsetroot
        - ttf-dejavu
{% else %}
install_desktop_packages_for_debian:
  pkg.installed:
    - pkgs:
        - suckless-tools
        - libx11-dev
        - libxft-dev
        - libxinerama-dev
        - xorg
        - xinit
        - x11-xserver-utils
{% endif %}

clone_dwm_repo:
  git.latest:
    - target: /etc/dwm
    - branch: master
    - name: git://git.suckless.org/dwm
    - rev: 6.2

write_build_dwm_script:
  file.managed:
    - name: /usr/local/bin/build_dwm.sh
    - source: salt://files/usr/local/bin/build_dwm.sh
    - user: root
    - group: root
    - mode: 755

build_dwm_if_needed:
  cmd.run:
    - name: /usr/local/bin/build_dwm.sh > /tmp/build_dwm_log 2>&1 &
    - onchanges:
        - git: clone_dwm_repo
        - git: clone_dotfiles_repo

symlink_xdefaults_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.Xdefaults
    - target: /etc/dotfiles/.Xdefaults
    - force: true

symlink_xinitrc_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.xinitrc
    - target: /etc/dotfiles/.xinitrc
    - force: true

create_terminator_config_directory:
  file.directory:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.config/terminator/
    - user: {{ pillar['shellserver_unprivileged_user_name'] }}
    - group: {{ pillar['shellserver_unprivileged_user_name'] }}
    - mode: 0755

symlink_terminator_config_to_unprivileged_user_home:
  file.symlink:
    - name: /home/{{ pillar['shellserver_unprivileged_user_name'] }}/.config/terminator/config
    - target: /etc/dotfiles/.config/terminator/config
    - force: true
    - require:
        - file: create_terminator_config_directory
