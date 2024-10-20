#!/usr/bin/bash

# This script waits for Rancher to become available on the rancher host and
# once it is, then it gets an API token and with that token retrieves the
# nodecommand (the command we need to execute to start up a k8s docker and
# join the already defined cluster). This way we can add any amount of vms
# to the cluster as soon as they come up, and rancher is up.

if test -e /usr/local/share/ca-certificates/rke.crt; then
    echo "Kubelet already installed"
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

echo "Giving Rancher some time to settle down"
sleep 30

echo "Installing rancher ca for self-signed certificate"
echo -e "$(curl -s https://{{ pillar['rancher_static_ip'] }}/v1/management.cattle.io.settings -H "Authorization: Bearer $LOGIN_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq . | grep value | grep "BEGIN CERTIFICATE" | cut -d '"' -f4  | head -n 1)" > /usr/local/share/ca-certificates/rke.crt
update-ca-certificates

echo "Waiting for cluster definition.."
while ! curl -s https://{{ pillar['rancher_static_ip'] }}/v3/clusters -H "Authorization: Bearer $LOGIN_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq -r '.data[] | select (.name == "homelabmanagerk8s").type' | grep -q cluster; do
    sleep 10
done

echo "Retrieving the node command"
NODE_ID=$(curl -s https://{{ pillar['rancher_static_ip'] }}/v3/clusters -H "Authorization: Bearer $LOGIN_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq -r '.data[] | select (.name == "homelabmanagerk8s").id')
NODE_COMMAND=$(curl -s https://{{ pillar['rancher_static_ip'] }}/v3/clusterregistrationtokens -H "Authorization: Bearer $API_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq -r ".data[] | select (.clusterId == \"$NODE_ID\").nodeCommand")
echo "Sleeping some random amount of time before joining the cluster"
if grep -q 'role: k8scontrolplane' /etc/salt/grains; then
  NODE_COMMAND="$NODE_COMMAND --etcd --controlplane"
  echo "Joining cluster as control plane by running $NODE_COMMAND in a bit.."
else
  NODE_COMMAND="$NODE_COMMAND --worker"
  echo "Joining cluster as a worker by running $NODE_COMMAND in a bit.."
  sleep 180
fi
sleep $((RANDOM % 180))

if docker ps | grep -q rancher; then
    echo "Rancher already running! No need to join the cluster, aborting"
    exit 0
fi

echo "Joining cluster now!"
$NODE_COMMAND
