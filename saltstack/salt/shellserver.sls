include:
  - storage

install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - wget
      - git
      - screen
