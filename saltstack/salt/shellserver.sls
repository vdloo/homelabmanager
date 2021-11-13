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

write_applied_states:
  cmd.run:
    - name: salt-call state.show_states concurrent=true --out json | jq -r '.local | .[]' > /srv/applied_states
