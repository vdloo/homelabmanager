install_shellserver_packages:
  pkg.installed:
    - pkgs:
      - curl
      - wget
    - refresh: true
