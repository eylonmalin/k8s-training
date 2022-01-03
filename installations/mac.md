# Install K8S cluster on your own Mac
1. Run this command without VPN/cooperate network
2. Reference guide: https://kind.sigs.k8s.io/docs/user/quick-start/
3. Install docker desktop for Mac:
https://docs.docker.com/desktop/mac/install/
4. Install kind
```shell
brew install kind
```
3. Create directory for lets-chat app:
```shell
   mkdir /tmp/letschat
```
4. Create k8s cluster
```shell
kind create cluster --config=kind-config.yaml
```
4. Validate by running
```shell
kubectl cluster-info --context kind-kind
```
