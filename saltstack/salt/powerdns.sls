include:
  - shellserver

stop_and_disable_systemd_resolved:
  service.dead:
    - enable: false
    - name: systemd-resolved

remove_resolv_conf_symlink_and_manage_file:
  file.managed:
    - name: /etc/resolv.conf
    - follow_symlinks: False
    - contents:
        - 'nameserver 8.8.8.8'
        - 'nameserver 8.8.4.4'

install_powerdns_packages:
  pkg.installed:
    - pkgs:
        - mariadb-server
        - pdns-server
        - pdns-recursor
        - pdns-backend-mysql
    - refresh: true

ensure_powerdns_config_dir:
  file.directory:
    - name: /etc/powerdns/pdns.d
    - user: root
    - group: root
    - mode: 755
    - makedirs: true

manage_pdns_authorative_server_config:
  file.managed:
    - name: /etc/powerdns/pdns.conf
    - source: salt://files/etc/powerdns/pdns.conf
    - user: root
    - group: root
    - mode: 600
    - require:
        - file: /etc/powerdns/pdns.d

manage_pdns_recursor_server_config:
  file.managed:
    - name: /etc/powerdns/recursor.conf
    - source: salt://files/etc/powerdns/recursor.conf
    - user: root
    - group: root
    - mode: 644
    - require:
        - file: /etc/powerdns/pdns.d

manage_pdns_mysql_config:
  file.managed:
    - name: /etc/powerdns/pdns.d/pdns.local.gmysql.conf
    - source: salt://files/etc/powerdns/pdns.d/pdns.local.gmysql.conf.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - require:
        - file: /etc/powerdns/pdns.d

configure_pdns_mysql_root_user:
  mysql_user.present:
    - host: localhost
    - password: {{ pillar['powerdns_mysql_password'] }}
    - name: root

configure_pdns_mysql_powerdns_user:
  mysql_user.present:
    - host: localhost
    - password: {{ pillar['powerdns_mysql_password'] }}
    - name: {{ pillar['powerdns_mysql_user'] }}
    - connection_user: root
    - connection_pass: {{ pillar['powerdns_mysql_password'] }}

configure_pdns_mysql_powerdns_database:
  mysql_database.present:
    - host: localhost
    - name: {{ pillar['powerdns_mysql_dbname'] }}
    - connection_user: root
    - connection_pass: {{ pillar['powerdns_mysql_password'] }}

grant_powerdns_user_on_powerdns_database:
  mysql_grants.present:
    - grant: all privileges
    - database: "{{ pillar['powerdns_mysql_dbname'] }}.*"
    - user: {{ pillar['powerdns_mysql_user'] }}
    - connection_user: root
    - connection_pass: {{ pillar['powerdns_mysql_password'] }}

load_initial_powerdns_schema:
  mysql_query.run_file:
    # From https://github.com/PowerDNS/pdns/blob/rel/auth-4.1.x/modules/gmysqlbackend/schema.mysql.sql
    - query_file: salt://files/tmp/initial_powerdns_schema
    - database: {{ pillar['powerdns_mysql_dbname'] }}
    - connection_user: root
    - connection_pass: {{ pillar['powerdns_mysql_password'] }}
    - onchanges:
      - file: /etc/powerdns/pdns.d/pdns.local.gmysql.conf

write_update_homelab_zone_script:
  file.managed:
    - name: /usr/local/bin/update_homelab_zone.sh
    - source: salt://files/usr/local/bin/update_homelab_zone.sh
    - user: root
    - group: root
    - mode: 755

update_homelab_zone:
  cmd.run:
    - name: /usr/local/bin/update_homelab_zone.sh
  require:
    - pkg: pdns-server

run_pdns_service:
  service.running:
    - enable: true
    - name: pdns
    - watch:
        - file: /etc/powerdns/pdns.d/pdns.local.gmysql.conf
        - file: /etc/powerdns/pdns.conf
  require:
    - pkg: pdns-server
    - pkg: pdns-recursor

run_pdns_recursor_service:
  service.running:
    - enable: true
    - name: pdns-recursor
    - watch:
        - file: /etc/powerdns/pdns.d/pdns.local.gmysql.conf
        - file: /etc/powerdns/recursor.conf
  require:
    - pkg: pdns-server
    - pkg: pdns-recursor
