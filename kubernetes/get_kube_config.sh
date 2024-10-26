#!/usr/bin/bash
#
# Run like: ./get_kube_config.sh -r <rancher host> -s <rancher secret>
# 
# Will output the kube config on stdout
#
set -e

while getopts "r:s:" opt; do
    case "$opt" in
        r)
            RANCHER_HOST="$OPTARG" ;;
        s)
            RANCHER_SECRET="$OPTARG" ;;
        esac
done

LOGIN_TOKEN=""
while ! grep -q token <<< "$LOGIN_TOKEN"; do
    LOGIN_TOKEN=$(curl -s "https://$RANCHER_HOST/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary "{\"username\":\"admin\",\"password\":\"$RANCHER_SECRET\"}" --insecure | jq -r .token)
    sleep 10
done

API_TOKEN=""
while ! grep -q token <<< "$API_TOKEN"; do
    API_TOKEN=$(curl -s "https://$RANCHER_HOST/v3/token" -H 'content-type: application/json' -H "Authorization: Bearer $LOGIN_TOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure | jq -r .token)
    sleep 10
done

NODE_ID=$(curl -s "https://$RANCHER_HOST/v3/clusters" -H "Authorization: Bearer $LOGIN_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq -r '.data[] | select (.name == "homelabmanagerk8s").id')

curl -X POST -s "https://$RANCHER_HOST/v3/clusters/$NODE_ID?action=generateKubeconfig" -H "Authorization: Bearer $LOGIN_TOKEN" -H 'content-type: application/json' --compressed --insecure | jq -r .config
