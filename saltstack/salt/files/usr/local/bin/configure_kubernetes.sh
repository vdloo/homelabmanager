#!/usr/bin/bash

# This script waits for Rancher to become available on the rancher host and
# once it is, then it gets an API token and with that token retrieves the
# nodecommand (the command we need to execute to start up a k8s docker and
# join the already defined cluster). This way we can add any amount of vms
# to the cluster as soon as they come up, and rancher is up.

if docker ps | grep -q rancher; then
    echo "Rancher already running!"
    exit 0
fi

echo "Waiting for Rancher to come up on the Rancher host"
while ! curl http://{{ pillar['rancher_static_ip'] }}/dashboard/auth/login 2>&1 | grep "/dashboard/" -q; do
    echo "Rancher is not up yet, will try again later.."
    sleep 120
done
echo "Rancher is up!"

echo "Waiting for login token.."
LOGIN_TOKEN=""
while ! grep -q token <<< "$LOGIN_TOKEN"; do
    LOGIN_TOKEN=$(curl -s "https://{{ pillar['rancher_static_ip'] }}/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"{{ pillar['rancher_secret'] }}"}' --insecure | jq -r .token)
    sleep 10
done
echo "Retrieved login token: $LOGIN_TOKEN"

echo "Waiting for API token.."
API_TOKEN=""
while ! grep -q token <<< "$API_TOKEN"; do
    API_TOKEN=$(curl -s 'https://{{ pillar['rancher_static_ip'] }}/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LOGIN_TOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure | jq -r .token)
    sleep 10
done
echo "Retrieved API token: $API_TOKEN"

echo "Giving Rancher some time to settle down, then proceeding with retrieving the node command"
sleep 30

echo "Waiting for cluster definition.."
while ! test $(curl -s https://{{ pillar['rancher_static_ip'] }}/v3/clusterregistrationtokens -H "Authorization: Bearer $LOGIN_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq .data | grep clusterId | grep -v local | wc -l) -ge 1; do
    sleep 10
done

echo "Retrieving the node command"
NODE_COMMAND=$(curl 'https://{{ pillar['rancher_static_ip'] }}/v3/clusterregistrationtokens' -H "Authorization: Bearer $API_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq .data[0].nodeCommand | tr -d '"')
echo "Joining cluster by running $NODE_COMMAND --etcd --controlplane --worker"
$NODE_COMMAND --etcd --controlplane --worker