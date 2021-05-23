include:
  - shellserver

install_jenkinsagent_packages:
  pkg.installed:
    - pkgs:
        - default-jdk
