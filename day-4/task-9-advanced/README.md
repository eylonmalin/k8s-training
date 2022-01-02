# Task-9-advanced: Persist Lets-Chat-APP into External Shared File-System Using **persistentVolumeClaim** Volume
In this task we would like to use PersistentVolumeClaim  to Lets-Chat-App pod so we could persist the upload files.
We will use kind Dynamic volume provisioning feature.
(you can read more about this feature here : https://github.com/kubernetes-sigs/kind/issues/118 and here: https://github.com/rancher/local-path-provisioner)
1. Create PersistentVolumeClaim for the PersistentVolume using **kubectl apply -f pvc.yaml** command
  > * Make sure the PersistentVolumeClaim is bounded to the PersistentVolume using **kubectl get pv**
2. Update the Lets-Chat-App deployment by adding it as a Volume the PersistentVolumeClaim
  > * The mountPath for persisting uploads should be /usr/src/app/uploads
3. Check in Browser, even after restart - the uploads in chat remain

  
### Specifications Examples

#### pvc.yaml
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-claim
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
```

#### pod-with-pvc.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    name: redis
    role: master
  name: test-storageos-redis-pvc
spec:
  containers:
    - name: master
      image: kubernetes/redis:v1
      env:
        - name: MASTER
          value: "true"
      ports:
        - containerPort: 6379
      resources:
        limits:
          cpu: "0.1"
      volumeMounts:
        - mountPath: /redis-master-data
          name: redis-data
  volumes:
    - name: redis-data
      persistentVolumeClaim:
        claimName: my-claim
```
