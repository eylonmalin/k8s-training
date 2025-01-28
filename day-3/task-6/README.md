# Task-6: Define ConfigMap and Secrets
In this task we woul like to get Environment Variables values from ConfigMap and Secret. The value of **CODE_ENABLED** in Lets-Chat-Web will be taken from ConfigMap. And we'll create new Environemnt Variables for Lets-Chat-App with DB user and password and their values will be taken from Secret.
1. Create ConfigMap in yaml file using **kubectl apply -f lc-config.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define config yaml file
  > * The ConfigMap should contain property **code.enabled: false**
2. Update Lets-Chat-Web Deployment to take the value of **CODE_ENABLED** from the ConfigMap
  > * Check what happens when you change the value in the configmap to "true"? Did the value in the pods auto changed?
3. Create Secret in yaml file using **kubectl apply -f db-secret.yaml** command
  > * The Secret should contain a property username, and value (pick any name) in base64
  > * The Secret should contain a property password, and value (pick any name) in base64
4. Update Lets-Chat-DB and Lets-Chat-APP Deployments to take the values from the Secret
  > * The Lets-Chat-DB should have 2 env variables named: **MONGO_INITDB_ROOT_USERNAME**, **MONGO_INITDB_ROOT_PASSWORD**
  > * The Lets-Chat-App should have another 2 env variables named: **MONGO_USER**, **MONGO_PASS**
  > * Verify The Lets-Chat-App is able to authenticate with the DB, when pods start
5. Update  Lets-Chat-DB and Lets-Chat-APP Deployments to take the values from KeyVault
  > * Create in your namespace a SecretProviderClass that can connect to the KeyVault
  > * Update the  Lets-Chat-DB deployment to read the secrets mongo-user and mongo-pass
  
### Specifications Examples
#### configmap.yaml
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  some.key: some.value
```
#### pod-with-configmap.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dapi-test-pod
spec:
  containers:
    - name: test-container
      image: k8s.gcr.io/busybox
      command: [ "/bin/sh", "-c", "env" ]
      env:
        # Define the environment variable
        - name: SPECIAL_LEVEL_KEY
          valueFrom:
            configMapKeyRef:
              # The ConfigMap containing the value you want to assign to SPECIAL_LEVEL_KEY
              name: my-config
              # Specify the key associated with the value
              key: some.key
  restartPolicy: Never
```
#### secret.yaml
First get the values in base64:
```bash
$ echo -n "admin" | base64
YWRtaW4=
$ echo -n "1f2d1e2e67df" | base64
MWYyZDFlMmU2N2Rm
```
The Secret:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```
#### pod-with-secret.yaml
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secret-env-pod
spec:
  containers:
  - name: mycontainer
    image: redis
    env:
      - name: SECRET_USERNAME
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: username
      - name: SECRET_PASSWORD
        valueFrom:
          secretKeyRef:
            name: mysecret
            key: password
  restartPolicy: Never
```

#### secret-provider-class.yaml
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: <SECRET_PROVIDER_CLASS_NAME>
spec:
  provider: azure
  parameters:
    cloudName: AzurePublicCloud
    keyvaultName: <KEYVAULT_NAME> # Set to the name of your key vault
    resourceGroup: <RESOURCE_GROUP>
    subscriptionId: <SUBSCRIPTION_ID>
    tenantId: <TENANT_ID>
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: <USER_ASSIGNED_IDENTITY_ID>   # Set the clientID of the user-assigned managed identity to use
    objects:  |
      array:
        - |
          objectName: <SECRET_NAME>            # keyvault secret name
          objectType: secret
  secretObjects:                             # Define the secretObjects to sync the secret to a Kubernetes secret
    - secretName: <K8S_SECRET_NAME>          # Name of the Kubernetes secret
      type: Opaque
      data:
        - objectName: <SECRET_NAME>             # Key Vault secret name
          key: <K8S_SECRET_KEY>                    # Key in the Kubernetes secret
```

#### pod-with-secret-from-keyvault.yaml
```yaml
kind: Pod
apiVersion: v1
metadata:
  name: sc-demo-keyvault-csi
spec:
  containers:
    - name: busybox
      image: registry.k8s.io/e2e-test-images/busybox:1.29-4
      command:
        - "/bin/sleep"
        - "10000"
      volumeMounts:
      - name: secrets-store01-inline
        mountPath: "/mnt/secrets-store"
        readOnly: true
      env:
      - name: MY_SPECIAL_SECRET
        valueFrom:
          secretKeyRef:
            name: <K8S_SECRET_NAME>   # Name of the Kubernetes secret
            key: <K8S_SECRET_KEY>     # Key in the Kubernetes secret  
  volumes:
    - name: secrets-store01-inline
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: "<SECRET_PROVIDER_CLASS_NAME>"
```
