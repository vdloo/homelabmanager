include:
  - shellserver

install_docker_repo_for_rancher:
  pkgrepo.managed:
    - name: "deb https://download.docker.com/linux/debian buster stable"
    - dist: buster
    - file: /etc/apt/sources.list.d/docker.list
    - humanname: Docker official repository
    - key_url: https://download.docker.com/linux/debian/gpg
    - refresh: true

install_docker_package_for_rancher:
  pkg.installed:
    - name: docker-ce
  require:
    - pkgrepo: "deb [arch=amd64] https://download.docker.com/linux/debian buster stable"

enable_docker_service:
  service.running:
    - enable: true
    - name: docker

run_rancher:
  cmd.run:
    - name: docker run --name rancher-server -d --restart=unless-stopped -p 80:80 -p 443:443 --privileged rancher/rancher:stable
