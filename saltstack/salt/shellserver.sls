include:
  - storage

install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - wget
      - git
      - screen
      - nmap
      - jq
      - python3-pip
      - python3-venv
