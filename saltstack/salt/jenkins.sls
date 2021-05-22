include:
  - shellserver

configure_firewall_rules_for_jenkins:
  file.managed:
    - name: /etc/iptables/rules.v4
    - source: salt://files/etc/iptables/rules.v4
    - user: root
    - group: root
    - mode: 644

load_jenkins_firewall_rules_on_change:
  cmd.run:
    - name: iptables-restore < /etc/iptables/rules.v4
    - watch:
      - file: /etc/iptables/rules.v4

jenkins_repository:
  pkgrepo.managed:
    - humanname: Jenkins Repo
    - name: deb https://pkg.jenkins.io/debian-stable binary/
    - file: /etc/apt/sources.list.d/jenkins.list
    - gpgcheck: 1
    - key_url: https://pkg.jenkins.io/debian-stable/jenkins.io.key

install_jenkins_packages:
  pkg.installed:
    - pkgs:
      - default-jdk
      - jenkins
    - refresh: true

ensure_jenkins_homedir:
  file.directory:
    - name: /mnt/storage/jenkins
    - user: jenkins
    - group: jenkins
    - mode: 755
    - makedirs: true

symlink_jenkins_home_from_storage:
  file.symlink:
    - name: /var/lib/jenkins
    - target: /mnt/storage/jenkins
    - force: True

enable jenkins service:
  service.running:
    - enable: true
    - name: jenkins
