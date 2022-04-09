#!jinja|yaml
---

{% if grains.oscodename == 'buster' %}
write_detect_debian_repo_script:
  file.managed:
    - name: /usr/local/bin/detect_debian_repo.sh
    - source: salt://files/usr/local/bin/detect_debian_repo.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja

detect_debian_repo:
  cmd.run:
    - name: /usr/local/bin/detect_debian_repo.sh > /tmp/detect_debian_repo_log 2>&1 &
{% endif %}

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
      - cronie
      - gnupg
      - inetutils
      - iptables
      - net-tools
{% else %}
install_core_packages_for_debian:
  pkg.installed:
    - pkgs:
      - cron
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

ensure_global_public_key_is_on_disk:
  file.managed:
    - name: /root/.ssh/id_rsa.pub
    - contents_pillar: public_key
    - user: root
    - group: root
    - mode: 644

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

{% if grains.role != 'openstack' %}
  cmd.run:
    - name: "ip route add 172.24.4.0/24 via {{ pillar['openstack_static_ip']  }}"
{% endif %}
