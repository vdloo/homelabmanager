nfs_hostname: ''
authorized_keys: []
private_key: ''
public_key: ''
powerdns_mysql_host: 'localhost'
powerdns_mysql_port: 3306
powerdns_mysql_dbname: 'powerdns'
powerdns_mysql_user: 'insecure_powerdns_user'
powerdns_mysql_password: 'insecure_powerdns_mysql_password'
powerdns_upstream_nameserver_1: '8.8.8.8'
powerdns_upstream_nameserver_2: '8.8.4.4'
powerdns_static_ip: '192.168.1.241'
prometheus_static_ip: '192.168.1.249'
debianrepo_static_ip: '192.168.1.252'
grafana_static_ip: '192.168.1.250'
irc_static_ip: '192.168.1.240'
vmsaltmaster_static_ip: '192.168.1.239'
shellserver_unprivileged_user_name: 'notroot'
shellserver_unprivileged_user_full_name: 'Not Root'
# Insecure default password is 'notroot'. Overwrite this in your own pillar.
shellserver_unprivileged_user_debian_password_hash: '$6$Fa4ELMtlTwOvhG50$JNbroT9R1Bj0QvER7PYw3Zxn2pnuA/uvj7obVJx0RXauLytV0xecEawUxKRhRaiIfjDWp1dn9tpCKoVd2OEBy/'
shellserver_unprivileged_user_archlinux_password_hash: '$6$SMIAJVy53kXVw9Us$BwgZeqK/qSbL.e.nC.J8afnQGWHov1YalGUWXNd6vmoWjMHlSgIeXkW0QWuxXLzVX//5XAz7GiudxvCT16XP9.'
# Insecure default consul secret. Overwrite this in your own pillar.
consul_secret: 'DC9Ih2OmseIrY04XKivB9Q=='
openstack_static_ip: '192.168.1.248'
openstack_stack_password: 'insecure_openstack_password'
rancher_secret: insecure_rancher_secret
rancher_static_ip: '192.168.1.247'
