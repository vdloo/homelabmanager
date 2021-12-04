#!jinja|yaml
---

create_storage_mount_directory:
  file.directory:
    - name: /mnt/storage
    - user: root
    - group: root
    - mode: 755
    - makedirs: true

create_disk_mount_directory:
  file.directory:
    - name: /mnt/disk
    - user: root
    - group: root
    - mode: 755
    - makedirs: true

{% if grains.os_family == 'Arch' %}
install_storage_packages_for_archlinux:
  pkg.installed:
    - pkgs:
      - nfs-utils
{% else %}
install_storage_packages_for_debian:
  pkg.installed:
    - pkgs:
      - nfs-common
{% endif %}

manage_fstab:
  file.managed:
    - name: /etc/fstab
    - source: salt://files/etc/fstab.j2
    - template: jinja
    - user: root
    - group: root
    - mode: 644

{% if pillar.get('nfs_hostname') %}
mount_storage_if_needed:
  cmd.run:
    - name: mount /mnt/storage
{% endif %}
