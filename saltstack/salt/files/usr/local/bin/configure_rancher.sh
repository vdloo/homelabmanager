#!/usr/bin/bash


if docker ps | grep -q rancher; then
    echo "Rancher already running!"
    exit 0
fi
echo "Starting Rancher container"
docker run -d --restart=unless-stopped -p 80:80 -p 443:443 \
    -e CATTLE_BOOTSTRAP_PASSWORD="{{ pillar['rancher_secret'] }}" \
    -e CATTLE_SERVER_URL="https://{{ pillar['rancher_static_ip'] }}" \
    --privileged rancher/rancher:latest

echo "Giving the container some time to start"
sleep 15

echo "Waiting for login token.."
LOGIN_TOKEN=""
while ! grep -q token <<< "$LOGIN_TOKEN"; do
    LOGIN_TOKEN=$(curl -s "https://127.0.0.1/v3-public/localProviders/local?action=login" -H 'content-type: application/json' --data-binary '{"username":"admin","password":"{{ pillar['rancher_secret'] }}"}' --insecure | jq -r .token)
    sleep 10
done
echo "Retrieved login token: $API_TOKEN"

echo "Waiting for API token.."
API_TOKEN=""
while ! grep -q token <<< "$API_TOKEN"; do
    API_TOKEN=$(curl -s 'https://127.0.0.1/v3/token' -H 'content-type: application/json' -H "Authorization: Bearer $LOGIN_TOKEN" --data-binary '{"type":"token","description":"automation"}' --insecure | jq -r .token)
    sleep 10
done
echo "Retrieved API token: $API_TOKEN"
