nfs_hostname: ''
authorized_keys: []
private_key: ''
powerdns_mysql_host: 'localhost'
powerdns_mysql_port: 3306
powerdns_mysql_dbname: 'powerdns'
powerdns_mysql_user: 'insecure_powerdns_user'
powerdns_mysql_password: 'insecure_powerdns_mysql_password'
powerdns_upstream_nameserver_1: '8.8.8.8'
powerdns_upstream_nameserver_2: '8.8.4.4'
powerdns_static_ip: '192.168.1.241'
prometheus_static_ip: '192.168.1.249'
shellserver_unprivileged_user_name: 'notroot'
shellserver_unprivileged_user_full_name: 'Not Root'
# Insecure default password is 'notroot'. Overwrite this in your own pillar.
shellserver_unprivileged_user_debian_password_hash: '$6$Fa4ELMtlTwOvhG50$JNbroT9R1Bj0QvER7PYw3Zxn2pnuA/uvj7obVJx0RXauLytV0xecEawUxKRhRaiIfjDWp1dn9tpCKoVd2OEBy/'
shellserver_unprivileged_user_archlinux_password_hash: '$6$SMIAJVy53kXVw9Us$BwgZeqK/qSbL.e.nC.J8afnQGWHov1YalGUWXNd6vmoWjMHlSgIeXkW0QWuxXLzVX//5XAz7GiudxvCT16XP9.'
