# Task-1: Deploy and Explore Lets-Chat-Web
1. Create a Pod of Lets-Chat-Web microservice using **kubectl run** command
  > * You can get the command options using ` kubectl run --help ` or use bellow [kubectl Cheat Sheet](#kubectl-cheat-sheet)
  > * The image of Lets-Chat-Web is **eylonmalin/lets-chat-web:v1**
  > * The lets-chat-web server is listening on port **80**
2. Explore the created pod:
  > * Which node the pod was scheduled to? 
  > * Has the pod container started successfully? Is it ready?
  > * Check the logs of the container. Do you like the little bear?
3. Expose the pod using **kubectl port-forward** command
  > * Open the browser and access the Lets-Chat-Web UI using the local port
  > * Crack the code to proceed to login page

### kubectl Cheat Sheet
  ```bash
# Start a single pod instance of my-app 
kubectl run my-app --image=my-app-image 

# create a deploymnet with my-app-image
kubectl create deployment my-app --image=my-app-image

# List all pods
kubectl get po

# List all pods with more information (such as node name).
kubectl get po -o wide

# Describe a pod with verbose output
kubectl describe po my-pod-name

# Return snapshot logs from pod 
kubectl logs my-pod-name

# Execute command in pod container and send stdout/stderr from 'sh' 
kubectl exec -it my-pod-name sh 

# Listen on port 8888 locally, forwarding to 5000 in the pod
kubectl port-forward my-pod-name 8888:5000

# Delete a pod
kubectl delete po my-pod-name

```
