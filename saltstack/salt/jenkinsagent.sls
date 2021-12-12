include:
  - jenkinsbase

write_connect_agent_script:
  file.managed:
    - name: /usr/local/bin/connect_jenkins_agent.sh
    - source: salt://files/usr/local/bin/connect_jenkins_agent.sh
    - user: root
    - group: root
    - mode: 755

check_connection_jenkins_agent_periodically:
    cron.present:
      - user: root
      - minute: '*/3'
      - name: /usr/local/bin/connect_jenkins_agent.sh

install_jenkinsagent_packages:
  pkg.installed:
    - pkgs:
        - salt-master

write_integration_test_saltmaster_configuration:
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

continuously_salt_agent_minions:
  cron.present:
    - user: root
    - minute: '*'
    - name: salt '*' state.apply > /dev/null 2>&1
