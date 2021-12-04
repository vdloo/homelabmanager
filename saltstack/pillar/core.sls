nfs_hostname: ''
authorized_keys: []
private_key: ''
powerdns_mysql_host: 'localhost'
powerdns_mysql_port: 3306
powerdns_mysql_dbname: 'powerdns'
powerdns_mysql_user: 'insecure_powerdns_user'
powerdns_mysql_password: 'insecure_powerdns_mysql_password'
shellserver_unprivileged_user_name: 'notroot'
shellserver_unprivileged_user_full_name: 'Not Root'
# Insecure default password is 'notroot'. Overwrite this in your own pillar.
shellserver_unprivileged_user_password_hash: '$6$Fa4ELMtlTwOvhG50$JNbroT9R1Bj0QvER7PYw3Zxn2pnuA/uvj7obVJx0RXauLytV0xecEawUxKRhRaiIfjDWp1dn9tpCKoVd2OEBy/'
