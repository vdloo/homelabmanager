#!/usr/bin/bash

# This script starts up Rancher (in a container) with a pre-defined bootstrap
# secret. Then that secret is used to create an API token. With that API token
# then API-calls are performed to enable the OpenStack NodeDriver as this is
# not enabled by default. Then a new cluster is created that uses the OpenStack
# driver.


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
sleep 5

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

echo "Enabling OpenStack Node Driver"
curl -H "Authorization: Bearer $API_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/nodeDrivers/openstack?action=activate' --insecure
sleep 5

echo "Importing nodeTemplate"
cat << EOF > /tmp/node_template.json
{
  "annotations": {
    "ownerBindingsCreated": "true"
  },
  "baseType": "nodeTemplate",
  "cloudCredentialId": null,
  "created": "2022-04-02T13:48:40Z",
  "createdTS": 1648907320000,
  "creatorId": "user-525cm",
  "driver": "openstack",
  "engineInstallURL": "https://releases.rancher.com/install-docker/20.10.sh",
  "engineRegistryMirror": [],
  "id": "cattle-global-nt:nt-r5ggd",
  "labels": {
    "cattle.io/creator": "norman"
  },
  "links": {
    "nodePools": "…/v3/nodePools?nodeTemplateId=cattle-global-nt%3Ant-r5ggd",
    "nodes": "…/v3/nodes?nodeTemplateId=cattle-global-nt%3Ant-r5ggd",
    "self": "…/v3/nodeTemplates/cattle-global-nt:nt-r5ggd",
    "update": "…/v3/nodeTemplates/cattle-global-nt:nt-r5ggd"
  },
  "name": "homelab",
  "openstackConfig": {
    "activeTimeout": "200",
    "applicationCredentialId": "",
    "applicationCredentialName": "",
    "applicationCredentialSecret": "",
    "authUrl": "http://{{  pillar['openstack_static_ip'] }}/identity/v3/auth/tokens",
    "availabilityZone": "nova",
    "bootFromVolume": false,
    "cacert": "",
    "configDrive": false,
    "domainId": "",
    "domainName": "default",
    "endpointType": "",
    "flavorId": "",
    "flavorName": "ds4G",
    "floatingipPool": "public",
    "imageId": "",
    "imageName": "focal-server-cloudimg-amd64",
    "insecure": true,
    "ipVersion": "4",
    "keypairName": "homelabkey",
    "privateKeyFile": "$(cat ~/.ssh/id_rsa | awk '{printf "%s\\n", $0}')",
    "netId": "",
    "netName": "private",
    "novaNetwork": false,
    "region": "RegionOne",
    "secGroups": "default",
    "sshPort": "22",
    "sshUser": "ubuntu",
    "tenantDomainId": "",
    "tenantDomainName": "",
    "tenantId": "",
    "tenantName": "demo",
    "userDataFile": "",
    "userDomainId": "",
    "userDomainName": "",
    "userId": "",
    "username": "demo",
    "password": "{{ pillar['openstack_stack_password'] }}",
    "volumeDevicePath": "",
    "volumeId": "",
    "volumeName": "",
    "volumeSize": "0",
    "volumeType": ""
  },
  "principalId": "local://user-525cm",
  "state": "active",
  "transitioning": "no",
  "transitioningMessage": "",
  "type": "nodeTemplate",
  "useInternalIpAddress": true,
  "uuid": "ba70e37a-fa2f-4231-82b6-bba0b2d85bc4"
}
EOF
curl -H "Authorization: Bearer $API_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/nodeTemplates' --insecure -d @/tmp/node_template.json
sleep 5

echo "Creating cluster"
cat << 'EOF' > /tmp/cluster.json
{
  "dockerRootDir": "/var/lib/docker",
  "enableClusterAlerting": false,
  "enableClusterMonitoring": false,
  "enableNetworkPolicy": false,
  "windowsPreferedCluster": false,
  "type": "cluster",
  "name": "homelab",
  "rancherKubernetesEngineConfig": {
    "addonJobTimeout": 45,
    "enableCriDockerd": false,
    "ignoreDockerVersion": true,
    "rotateEncryptionKey": false,
    "sshAgentAuth": false,
    "type": "rancherKubernetesEngineConfig",
    "kubernetesVersion": "v1.22.7-rancher1-2",
    "authentication": {
      "strategy": "x509",
      "type": "authnConfig"
    },
    "dns": {
      "type": "dnsConfig",
      "nodelocal": {
        "type": "nodelocal",
        "ip_address": "",
        "node_selector": null,
        "update_strategy": {}
      }
    },
    "network": {
      "mtu": 0,
      "plugin": "canal",
      "type": "networkConfig",
      "options": {
        "flannel_backend_type": "vxlan"
      }
    },
    "ingress": {
      "defaultBackend": false,
      "defaultIngressClass": true,
      "httpPort": 0,
      "httpsPort": 0,
      "provider": "nginx",
      "type": "ingressConfig"
    },
    "monitoring": {
      "provider": "metrics-server",
      "replicas": 1,
      "type": "monitoringConfig"
    },
    "services": {
      "type": "rkeConfigServices",
      "kubeApi": {
        "alwaysPullImages": false,
        "podSecurityPolicy": false,
        "serviceNodePortRange": "30000-32767",
        "type": "kubeAPIService",
        "secretsEncryptionConfig": {
          "enabled": false,
          "type": "secretsEncryptionConfig"
        }
      },
      "etcd": {
        "creation": "12h",
        "extraArgs": {
          "heartbeat-interval": 500,
          "election-timeout": 5000
        },
        "gid": 0,
        "retention": "72h",
        "snapshot": false,
        "uid": 0,
        "type": "etcdService",
        "backupConfig": {
          "enabled": true,
          "intervalHours": 12,
          "retention": 6,
          "safeTimestamp": false,
          "timeout": 300,
          "type": "backupConfig"
        }
      }
    },
    "upgradeStrategy": {
      "maxUnavailableControlplane": "1",
      "maxUnavailableWorker": "10%",
      "drain": "false",
      "nodeDrainInput": {
        "deleteLocalData": false,
        "force": false,
        "gracePeriod": -1,
        "ignoreDaemonSets": true,
        "timeout": 120,
        "type": "nodeDrainInput"
      },
      "maxUnavailableUnit": "percentage"
    }
  },
  "localClusterAuthEndpoint": {
    "enabled": true,
    "type": "localClusterAuthEndpoint"
  },
  "labels": {},
  "annotations": {},
  "agentEnvVars": [],
  "scheduledClusterScan": {
    "enabled": false,
    "scheduleConfig": null,
    "scanConfig": null
  }
}
EOF
curl -H "Authorization: Bearer $API_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/clusters?_replace=true' --insecure -d @/tmp/cluster.json
sleep 5

echo "Getting the ID of the newly created cluster"
CLUSTER_ID_WITH_QUOTES=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/clusters' --insecure  | jq '.data | map({key: .name, value: .id}) | .[].value' | grep -v local | head -n 1)
sleep 5

echo "Getting the ID of the OpenStack NodeTemplate that we created before"
NODE_TEMPLATE_ID_WITH_QUOTES=$(curl -s -H "Authorization: Bearer $API_TOKEN" -X GET -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/nodeTemplate' --insecure | jq '.data | .[].id')
sleep 5

echo "Creating nodepool for cluster"
cat << EOF > /tmp/nodepool.json
{
  "controlPlane": true,
  "deleteNotReadyAfterSecs": 0,
  "drainBeforeDelete": false,
  "etcd": true,
  "quantity": 5,
  "worker": true,
  "type": "nodePool",
  "nodeTemplateId": $NODE_TEMPLATE_ID_WITH_QUOTES,
  "clusterId": $CLUSTER_ID_WITH_QUOTES,
  "hostnamePrefix": "homelab"
}
EOF
curl -H "Authorization: Bearer $API_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/nodepool' --insecure -d @/tmp/nodepool.json
sleep 5
