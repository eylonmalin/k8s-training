# Task-9: Volume Mount Directory from the Node File-System
In this task we would like to persist the DB data to external storage.
In kind-worker node there is a mount at /var/letschat to your local machine /tmp/letschat.
We would persist DB data to this directory.
1. Add label to one of the nodes using **kubectl label node kind-worker app=letschat** command
2. Add nodeSelector to the Lets-Chat-DB Deployment
3. Add volume to the hostPath volumeMonut to that volume
  > * The mountPath for persisting mongodb should be /var/letschat
  > * The hostPath (in this case) is also /var/letschat 
3. Check in Browser, even after restart pod User is persistent

  
### Specifications Examples
#### pod-with-hostPath.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pd
spec:
  containers:
  - image: k8s.gcr.io/test-webserver
    name: test-container
    volumeMounts:
    - mountPath: /test-pd
      name: test-volume
  volumes:
  - name: test-volume
    hostPath:
      # directory location on host
      path: /data
      # this field is optional
      type: Directory
```
#### pod-with-node-selector.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
  labels:
    env: test
spec:
  containers:
  - name: nginx
    image: nginx
    imagePullPolicy: IfNotPresent
  nodeSelector:
    disktype: ssd
```
