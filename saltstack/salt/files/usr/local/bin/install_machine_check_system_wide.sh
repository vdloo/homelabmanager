#!/usr/bin/bash
set -e
cd /etc/machine-check
raco pkg install --deps search-auto
cp /srv/machine-check/* checks-to-perform/
make clean
cat << EOF > /sbin/machine-check
#!/usr/bin/bash
cd /etc/machine-check
racket main.rkt
EOF
chmod +x /sbin/machine-check
