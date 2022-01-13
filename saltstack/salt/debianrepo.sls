include:
  - shellserver

create_debianrepo_conf_directory:
  file.directory:
    - name: /mnt/storage/debianrepo/conf
    - user: root
    - group: root
    - mode: 0755
    - makedirs: true

symlink_srv_reprepro_to_debianrepo:
  file.symlink:
    - name: /srv/reprepro
    - target: /mnt/storage/debianrepo
    - force: true

write_debianrepo_reprepro_distributions:
  file.managed:
    - name: /mnt/storage/debianrepo/conf/distributions
    - source: salt://files/mnt/storage/debianrepo/conf/distributions
    - user: root
    - group: root
    - mode: 644

write_debianrepo_reprepro_updates:
  file.managed:
    - name: /mnt/storage/debianrepo/conf/updates
    - source: salt://files/mnt/storage/debianrepo/conf/updates
    - user: root
    - group: root
    - mode: 644

write_debianrepo_reprepro_options:
  file.managed:
    - name: /mnt/storage/debianrepo/conf/options
    - source: salt://files/mnt/storage/debianrepo/conf/options
    - user: root
    - group: root
    - mode: 644

install_sync_debianrepo_script:
  file.managed:
    - name: /usr/local/bin/sync_debianrepo.sh
    - source: salt://files/usr/local/bin/sync_debianrepo.sh
    - user: root
    - group: root
    - mode: 755

install_debianrepo_packages:
  pkg.installed:
    - pkgs:
        - reprepro
        - nginx

remove_default_nginx_vhost_on_debian_repo:
  file.absent:
    - name: /etc/nginx/sites-enabled/default

configure_debian_repo_nginx_vhost:
  file.managed:
    - name: /etc/nginx/sites-enabled/debianrepo
    - source: salt://files/etc/nginx/sites-enabled/debianrepo
    - user: root
    - group: root
    - mode: 644

run_nginx_service:
  service.running:
    - enable: true
    - name: nginx
    - watch:
        - file: /etc/nginx/sites-enabled/default
        - file: /etc/nginx/sites-enabled/debianrepo
