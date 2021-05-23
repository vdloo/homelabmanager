install_core_packages:
  pkg.installed:
    - pkgs:
      - htop
      - iftop
      - gnupg2
      - sysstat
      - iptables-persistent
    - refresh: true

ensure_global_key_is_on_disk:
  file.managed:
    - name: /root/.ssh/id_rsa
    - contents_pillar: private_key
    - user: root
    - group: root
    - mode: 600

{% if pillar.get('authorized_keys') %}
ensure_authorized_keys:
  ssh_auth.present:
    - user: root
    - names:
      {% for key in pillar['authorized_keys'] %}
      - {{ key }}
      {% endfor %}
{% endif %}
