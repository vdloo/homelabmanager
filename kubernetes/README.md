Kubernetes
==========

This is where the Kubernetes related files such as deployments files and
helper scripts are placed.

To keep the kube config up to date put this in a cron:
```
./get_kube_config.sh -r <rancher host> -s <rancher secret> > ~/.kube/config
```
