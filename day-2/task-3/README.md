# Task-3: Rolling-Update Lets-Chat-Web
1. Delete the previous Deployment of Lets-Chat-Web microservice, using **kubectl delete deploy** command.
2. Create new Deployment using **kubectl apply -f web-deploy.yaml** command
  > * You can use bellow [Specifications Examples](#specifications-examples) to define the yaml files
  > * The Image name of Lets-Chat-Web:  **eylonmalin/lets-chat-web:v1**
  > * The label of the deployment should be `app: lc-web`
  > * The Web server is listening on port 80
  > * The deployment should run 3 pods 
  > * Disable the code feature by configuring the Lets-Chat-Web with environment variable name: **CODE_ENABLED** and value "false".
  > * Add a second label to the pods (in spec.template.labels of web-deploy.yaml) of **version:v1** 
3. Create a Service to Lets-Chat-Web microservice using **kubectl apply -f web-svc.yaml** command
  > * The service type of this microservice should be ClusterIp
  > * The port should be 31999
  > * The selector should match the deployment label
4. Verify the pods are ready, and you are able to access Lets-Chat-Web UI via browser using node-port
  > * Use port-forward to expose the port in your local machine.  Then open the browser and access Lets-Chat-Web UI using localhost:31999.
  > * Check the logs of the pods - and see it runs v1 image
5. Update the deployment, using `kubectl apply -f web-deploy.yaml` command, and change the image to **eylonmalin/lets-chat-web:v2** and also change the label to **version: v2** in spec.template.metadata.labels
  > * Explore the pods rolling update using `kubectl get po --show-labels`
  > * Verify the update using `kubectl logs new-pod-name`
6. Rollback to the previous deployment using `kubectl rollout undo deployment deploy-name`
  > * Explore the pods rollback using `kubectl get po --show-labels`
  > * Verify the update using `kubectl logs new-pod-name`

### Specifications Examples
#### nginx-svc.yaml
```yaml
kind: Service
apiVersion: v1
metadata:
  name: nginx  # The name of your service
spec:
  selector:
    app: nginx  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    nodePort: 31999 # the node(external) port
    port: 80 # The service port
  type: ClusterIP # [OPTIONAL] in case of ClusterIP you can drop this line 
```
#### nginx-deploy.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment # The name of your deployment
  labels: # The label of the deployment itself
    app: nginx 
spec:
  replicas: 1 # Number of replicated pods
  selector:
    matchLabels:
      app: nginx # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: nginx # The label of the pod
    spec:
      containers:
      - name: nginx # The container name
        image: nginx:1.7.9 # The DockerHub image
        ports:
        - containerPort: 80 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: SOME_ENV_NAME
          value: some-env-value
```
