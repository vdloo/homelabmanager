include:
  - jenkinsbase
  - saltmaster

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

continuously_salt_agent_minions:
  cron.present:
    - user: root
    - minute: '*'
    - name: salt '*' state.apply > /dev/null 2>&1
