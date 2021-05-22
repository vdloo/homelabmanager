install_core_packages:
  pkg.installed:
    - pkgs:
      - htop
      - iftop
    - refresh: true
