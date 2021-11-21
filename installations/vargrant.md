# Install K8S cluster by using vargrant

##### Requirements
* [Vagrant](https://www.vagrantup.com/downloads)
* [VirtualBox](https://www.virtualbox.org/)

Run

```
vagrant init navivi/k8s-training --box-version 1
vagrant up
```

Show the desktop VM from VirtualBox,

Login Credentials are:

- Username: vagrant

- Password: vagrant

![image](https://user-images.githubusercontent.com/34754379/118403830-f81e5400-b678-11eb-949a-b2b3f03db72c.png)

Open the Terminal, by clicking the 'Show Applications' at the left bottom and search 'Terminal'

![image](https://user-images.githubusercontent.com/34754379/118403954-90b4d400-b679-11eb-97ec-a53b8f7f33a8.png)

In the terminal, run:
```
./kube-ssh
kind create cluster --config kind.yaml
```

It may take few minutes to create the kubernetes cluster...

Once it is done, check the cluster is up and ready by runinng:
```
kubectl get nodes
```
![image](https://user-images.githubusercontent.com/34754379/118404499-d4a8d880-b67b-11eb-9cd1-30d012f42de0.png)
