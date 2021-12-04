#!/bin/bash
set -e
JENKINSCIHOST="localhost:8321"
DEAD_AGENTS=$(curl -s $JENKINSCIHOST/computer/api/json?pretty=true | jq '.computer[] | select (.offline == true) .displayName' | grep -v default | sed 's/"//g' | sed 's/\n/ /g')
echo $DEAD_AGENTS
wget -nc $JENKINSCIHOST/jnlpJars/jenkins-cli.jar
if [ -z "$DEAD_AGENTS" ]; then
    echo "No dead agents"
    exit 0
fi
for JENKINSAGENT in $DEAD_AGENTS; do
  java -jar jenkins-cli.jar -s http://$JENKINSCIHOST delete-node $JENKINSAGENT || /bin/true
done
