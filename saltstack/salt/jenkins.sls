include:
  - shellserver

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

run_jenkins_on_port_80:
  file.line:
    - name: /etc/default/jenkins
    - mode: replace
    - match: HTTP_PORT=8080
    - content: HTTP_PORT=80
  require:
    - pkg: jenkins

enable jenkins service:
  service.running:
    - enable: true
    - name: jenkins
    - watch:
        - file: /etc/default/jenkins
