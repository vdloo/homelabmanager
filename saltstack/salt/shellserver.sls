include:
  - storage

install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - wget
      - git
      - screen
      - nmap
      - jq
      - python3-pip
      - python3-venv
      - python3-mysqldb
      - python3-sqlparse
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

clone machine check repo:
  git.latest:
    - target: /etc/machine-check
    - branch: master
    - name: https://github.com/vdloo/machine-check

install machine-check:
  cmd.run:
    - name: raco pkg install --deps search-auto
    - cwd: /etc/machine-check
    - onchanges:
      - git: clone machine check repo
