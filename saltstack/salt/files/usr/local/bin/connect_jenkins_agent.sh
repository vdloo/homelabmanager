#!/bin/bash
set -e
JENKINS_IP=$(nmap -n -Pn 192.168.1.0/24 -p8321 -oG - | grep '/open/' | awk '/Host:/{print $2}' | head -n 1)
AGENT_IP=$(ip route get 192.168.1.16 | awk '{print$5}'| head -n 1)
if [ -z "$JENKINS_IP" ]; then
    echo "No Jenkins found"
    exit 0
fi
wget -nc $JENKINS_IP/jnlpJars/jenkins-cli.jar
if java -jar jenkins-cli.jar -s http://$JENKINS_IP get-node $(hostname) | grep -q $AGENT_IP; then
    echo "Already connected"
    exit 0
fi
java -jar jenkins-cli.jar -s http://$JENKINS_IP delete-node $(hostname) || /bin/true
java -jar jenkins-cli.jar -s http://$JENKINS_IP get-node default | sed "s/1.2.3.4/$AGENT_IP/g" | java -jar jenkins-cli.jar -s http://$JENKINS_IP create-node $(hostname)
