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

install_storage_packages:
  pkg.installed:
    - pkgs:
      - nfs-common

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
