# Install K8S cluster on your own Windows
1. Run this command without VPN/cooperate network
2. Reference guide: https://kind.sigs.k8s.io/docs/user/quick-start/
3. Install docker desktop for Windows:
   1. https://docs.docker.com/desktop/windows/install/
   2. Pay attention to WSL 2 backend
4. Install kind
   1) Download https://kind.sigs.k8s.io/dl/v0.11.1/kind-windows-amd64
   2) Rename the downloaded file to kind.exe
   3) Copy kind.exe to some path where you keep exe tools (like C:/app)
5. (Optional) install cmder from here : https://cmder.net/
6. Install kubectl: Download [kubectl.exe](https://dl.k8s.io/release/v1.23.0/bin/windows/amd64/kubectl.exe) and save the file
in same directory of kind.exe 
7. Download [kind-config.yaml](kind-config.yaml) and save the fie in same directory of kind.exe
8. Create directory for our lets-chat app: C:\tmp\letschat
9. Create k8s cluster. Run the command from the directory of kind.exe
```shell
kind.exe create cluster --config=kind-config.yaml
```
10.Validate installation by running
```shell
kubectl cluster-info --context kind-kind
```
