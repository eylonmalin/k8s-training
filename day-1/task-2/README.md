# Task-2: Deploy, Expose and Scale Lets-Chat-Web
1. Create a Deployment of Lets-Chat-Web microservice using **kubectl create deploy** command with image eylonmalin/lets-chat-web:v1
  > * You can get the command options using ` kubectl create --help ` or use bellow [kubectl Cheat Sheet](#kubectl-cheat-sheet)
1. Create a Service to Lets-Chat-Web microservice using **kubectl expose deploy** command
  > * Get the Service Cluster-IP using `kubectl get svc` command. Then access one of the nodes in the cluster using `docker exec -it kind-worker bash`, and there curl service-cluster-ip:service-port.
2. Change the Service type from ClusterIP to NodePort to make it accessible from outside the cluster.
  * Use `kubectl edit svc my-service-name` to update the service specification with **type: NodePort**
  * Config both port and nodePort to port 31999 (see example bellow) 
  * Get the Service Node port using `kubectl get svc` command. Then open the browser and acceess Lets-Chat-Web UI using localhost:31999.
3. Scale the Lets-Chat-Web pods to 4 instances using  **kubectl scale** command
  > * Explore the pods, using `kubectl get po -o wide`, to see which Nodes the new pods were scheduled to.
4. Scale down the Lets-Chat-Web pods to 2 instances. Now they are running on 2 nodes.

### kubectl Cheat Sheet
  ```bash
# Create a deployment with single pod
kubectl create deploy my-app --image nginx

# List all deployments
kubectl get deploy

# Create a service for my-app deployment, on port 32000 and connects to the containers on port 80.
kubectl expose deployment my-app --port=32000 --target-port=80

# List all services
kubectl get svc

# Open vi editor to the service specification where you can update its state
kubectl edit svc my-svc-name

# List pods and show all labels as the last column
kubectl get po --show-labels

# Scale a deployment named 'foo' to 3.
kubectl scale deploy my-app --replicas=3

# Delete deployment and all its pods
kubectl delete deploy my-deployment-name

# Delete a service
kubectl delete svc my-svc-name

```

###NodePort config example:
```
ports:
- nodePort: 31999
  port: 31999
  protocol: TCP
  targetPort: 80
type: NodePort
```