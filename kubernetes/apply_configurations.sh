#!/usr/bin/bash
set -e
SCRIPT_DIR="$(dirname -- "$BASH_SOURCE"; )";

echo "Creating fresh temporary directory"
rm -rf /tmp/kubernetes_configurations
mkdir /tmp/kubernetes_configurations
cp -R $SCRIPT_DIR/* /tmp/kubernetes_configurations
cd /tmp/kubernetes_configurations

# See https://prometheus-operator.dev/docs/getting-started/installation/
echo "Installing kube-prometheus"
git clone https://github.com/prometheus-operator/kube-prometheus.git
cd kube-prometheus
if ! kubectl get servicemonitors --all-namespaces | grep -q prometheus; then
    kubectl create -f manifests/setup
    until kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo; done
    kubectl create -f manifests/
fi
cd ..

# See https://github.com/blakeblackshear/blakeshome-charts/tree/master/charts/frigate
echo "Installing frigate"
helm repo add blakeblackshear https://blakeblackshear.github.io/blakeshome-charts/
helm upgrade --install my-release blakeblackshear/frigate -f frigate/values.yaml
