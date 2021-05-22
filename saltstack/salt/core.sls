install_core_packages:
  pkg.installed:
    - pkgs:
      - htop
      - iftop
      - gnupg2
      - sysstat
      - iptables-persistent
    - refresh: true

{% if pillar.get('authorized_keys') %}
ensure_authorized_keys:
  ssh_auth.present:
    - user: root
    - names:
      {% for key in pillar['authorized_keys'] %}
      - {{ key }}
      {% endfor %}
{% endif %}
