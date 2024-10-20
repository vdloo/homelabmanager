include:
  - jenkinsbase

jenkins_repository:
  pkgrepo.managed:
    - humanname: Jenkins Repo
    - name: deb https://pkg.jenkins.io/debian-stable binary/
    - file: /etc/apt/sources.list.d/jenkins.list
    - gpgcheck: 1
    - key_url: https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

install_jenkinsci_packages:
  pkg.installed:
    - pkgs:
      - jenkins
    - refresh: true

ensure_jenkins_homedir:
  file.directory:
    - name: /mnt/storage/jenkins
    - user: jenkins
    - group: jenkins
    - mode: 755
    - makedirs: true
    - recurse:
      - user
      - group
      - mode

ensure_jenkins_ssh_dir:
  file.directory:
    - name: /var/lib/jenkins/.ssh
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: true
    - require:
      - file: /var/lib/jenkins

symlink_jenkins_home_from_storage:
  file.symlink:
    - name: /var/lib/jenkins
    - target: /mnt/storage/jenkins
    - force: true

ensure_jenkins_ssh_key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_ed25519
    - contents_pillar: private_key
    - user: jenkins
    - group: jenkins
    - mode: 600

run_jenkins_on_port_80:
  file.line:
    - name: /etc/default/jenkins
    - mode: replace
    - match: HTTP_PORT=8080
    - content: HTTP_PORT=8321
  require:
    - pkg: jenkins

enable_jenkins_service:
  service.running:
    - enable: true
    - name: jenkins
    - watch:
        - file: /etc/default/jenkins

write_clean_up_dead_agents_script:
  file.managed:
    - name: /usr/local/bin/clean_up_dead_agents.sh
    - source: salt://files/usr/local/bin/clean_up_dead_agents.sh
    - user: root
    - group: root
    - mode: 755

clean_up_dead_jenkins_agents_periodically:
  cron.present:
    - user: root
    - minute: '*/10'
    - name: /usr/local/bin/clean_up_dead_agents.sh
