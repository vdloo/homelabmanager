install_saltmaster_packages:
  pkg.installed:
    - pkgs:
        - salt-master

write_saltmaster_configuration:
  file.managed:
    - name: /etc/salt/master
    - source: salt://files/etc/salt/master
    - user: root
    - group: root
    - mode: 644

clean_up_dead_saltmaster_agent_minions_periodically:
  cron.present:
    - user: root
    - minute: '*/3'
    - name: salt-run manage.down removekeys=True > /dev/null 2>&1
