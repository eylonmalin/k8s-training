# Install K8S cluster on your own Mac
1. Run this command without VPN/cooperate network
2. Reference guide: https://kind.sigs.k8s.io/docs/user/quick-start/
3. Install docker desktop for Mac:
https://docs.docker.com/desktop/mac/install/
4. Install kubectl
```shell
brew install kubectl
```
5. Install kind
```shell
brew install kind
```
6. Create directory for lets-chat app:
```shell
   mkdir /tmp/letschat
```
7. Download [kind-config.yaml](kind-config.yaml) 
8. Create k8s cluster. Run the command from same dir of kind-config.yaml
```shell
kind create cluster --config=kind-config.yaml
```
9. Validate by running
```shell
kubectl cluster-info --context kind-kind
```
