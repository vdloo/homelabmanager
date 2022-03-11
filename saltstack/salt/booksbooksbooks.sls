include:
  - shellserver

write_booksbooksbooks_service_unit:
  file.managed:
    - name: /usr/lib/systemd/system/booksbooksbooks.service
    - source: salt://files/usr/lib/systemd/system/booksbooksbooks.service
    - user: root
    - group: root
    - mode: 644

daemon_reload_if_booksbooksbooks_unit_changed:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
        - file: /usr/lib/systemd/system/booksbooksbooks.service

install_booksbooksbooks_packages:
  pkg.installed:
    - pkgs:
        - libxml2-dev
        - libffi-dev

clone_books_books_books_repo:
  git.latest:
    - target: /etc/booksbooksbooks
    - branch: master
    - name: https://github.com/vdloo/booksbooksbooks

write_install_books_books_books_script:
  file.managed:
    - name: /usr/local/bin/install_books_books_books.sh
    - source: salt://files/usr/local/bin/install_books_books_books.sh
    - user: root
    - group: root
    - mode: 755

install_books_books_books_if_needed:
  cmd.run:
    - name: /usr/local/bin/install_books_books_books.sh > /tmp/install_books_books_books_log 2>&1 &
    - onchanges:
      - git: clone_books_books_books_repo
  require:
    - pkg: libffi-dev
