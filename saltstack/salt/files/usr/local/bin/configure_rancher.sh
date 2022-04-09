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

echo "Enabling OpenStack Node Driver"
curl -H "Authorization: Bearer $API_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/nodeDrivers/openstack?action=activate' --insecure
sleep 15

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
    "flavorName": "ds2G",
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
sleep 15

echo "Creating cluster"
cat << 'EOF' > /tmp/cluster.json
{
  "answers": {},
  "docker_root_dir": "/var/lib/docker",
  "enable_cluster_alerting": false,
  "enable_cluster_monitoring": false,
  "enable_network_policy": false,
  "fleet_workspace_name": "fleet-default",
  "local_cluster_auth_endpoint": {
    "enabled": true
  },
  "name": "homelab",
  "rancher_kubernetes_engine_config": {
    "addon_job_timeout": 45,
    "authentication": {
      "strategy": "x509|webhook"
    },
    "authorization": {},
    "bastion_host": {
      "ignore_proxy_env_vars": false,
      "ssh_agent_auth": false
    },
    "cloud_provider": {},
    "dns": {
      "linear_autoscaler_params": {},
      "node_selector": null,
      "nodelocal": {
        "node_selector": null,
        "update_strategy": {
          "rolling_update": {}
        }
      },
      "options": null,
      "reversecidrs": null,
      "stubdomains": null,
      "tolerations": null,
      "update_strategy": {},
      "upstreamnameservers": null
    },
    "enable_cri_dockerd": false,
    "ignore_docker_version": true,
    "ingress": {
      "default_backend": false,
      "default_ingress_class": true,
      "http_port": 0,
      "https_port": 0,
      "provider": "nginx"
    },
    "kubernetes_version": "v1.22.7-rancher1-2",
    "monitoring": {
      "provider": "metrics-server",
      "replicas": 1
    },
    "network": {
      "mtu": 0,
      "options": {
        "flannel_backend_type": "vxlan"
      },
      "plugin": "canal"
    },
    "restore": {
      "restore": false
    },
    "rotate_encryption_key": false,
    "services": {
      "etcd": {
        "backup_config": {
          "enabled": true,
          "interval_hours": 12,
          "retention": 6,
          "safe_timestamp": false,
          "timeout": 300
        },
        "creation": "12h",
        "extra_args": {
          "election-timeout": "5000",
          "heartbeat-interval": "500"
        },
        "gid": 0,
        "retention": "72h",
        "snapshot": false,
        "uid": 0
      },
      "kube-api": {
        "always_pull_images": false,
        "pod_security_policy": false,
        "secrets_encryption_config": {
          "enabled": false
        },
        "service_node_port_range": "30000-32767"
      },
      "kube-controller": {},
      "kubelet": {
        "fail_swap_on": false,
        "generate_serving_certificate": false
      },
      "kubeproxy": {},
      "scheduler": {}
    },
    "ssh_agent_auth": false,
    "upgrade_strategy": {
      "max_unavailable_controlplane": "1",
      "max_unavailable_worker": "10%",
      "node_drain_input": {
        "delete_local_data": false,
        "force": false,
        "grace_period": -1,
        "ignore_daemon_sets": true,
        "timeout": 120
      }
    }
  }
}
EOF
curl -H "Authorization: Bearer $API_TOKEN" -X POST -H 'Accept: application/json' -H 'Content-Type: application/json' 'https://127.0.0.1/v3/clusters' --insecure -d @/tmp/cluster.json
