include:
  - shellserver

install_jenkinsbase_packages:
  pkg.installed:
    - pkgs:
        - default-jdk
