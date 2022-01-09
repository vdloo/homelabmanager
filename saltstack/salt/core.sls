#!jinja|yaml
---

install_core_packages:
  pkg.installed:
    - pkgs:
      - htop
      - iftop
      - sysstat
    - refresh: true

{% if grains.os_family == 'Arch' %}
install_core_packages_for_archlinux:
  pkg.installed:
    - pkgs:
      - bind
      - gnupg
      - iptables
      - inetutils
{% else %}
install_core_packages_for_debian:
  pkg.installed:
    - pkgs:
      - dnsutils
      - gnupg2
      - iptables-persistent
{% endif %}

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

reboot_five_seconds_after_kernel_panic:
  sysctl.present:
    - name: kernel.panic
    - value: 5

reboot_on_hung_tasks_to_deal_with_nfs_problems:
  sysctl.present:
    - name: kernel.hung_task_timeout_secs
    - value: 180
