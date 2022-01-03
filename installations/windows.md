# Install K8S cluster on your own Windows
1. Run this command without VPN/cooperate network
2. Reference guide: https://kind.sigs.k8s.io/docs/user/quick-start/
3. Install docker desktop for Windows:
   1. https://docs.docker.com/desktop/windows/install/
   2. Pay attention to WSL 2 backend
4. Install kind
   1) Download https://kind.sigs.k8s.io/dl/v0.11.1/kind-windows-amd64
   2) Rename the downloaded file to kind.exe
   3) Copy kind.exe to some path where you keep exe tools (like C:/app). We would Call it KIND_PATH
5. (Optional) install cmder from here : https://cmder.net/
6. Create directory for our lets-chat app: C:\tmp\letschat
7. Create k8s cluster
```shell
KIND_PATH/kind.exe create cluster --config=kind-config.yaml
```
8. Validate by running
```shell
kubectl cluster-info --context kind-kind
```
