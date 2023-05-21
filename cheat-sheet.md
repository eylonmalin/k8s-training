# Kubernetes cheat sheet

Formal k8s cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/

## Apply changes to any resource
```bash
kubectl apply -f resource-file.yaml   # Create/update resource from file
````

## Pod
```bash
kubectl get po                        # list pods and their status
kubectl get po foo                    # Show one pod named foo
kubectl describe po foo               # Show details of pod named foo
kubectl get po foo -o yaml            # Show the pod as yaml file
kubectl apply -f resource-file.yaml   # Create/update resource from file
kubectl exec foo -- curl localhost:80 # Exec command and exit
kubectl exec foo -it -- sh            # Provide shell in the pod (like ssh)
kubectl logs foo                      # Print logs of the pod (by its name)
kubectl logs -f foo                   # Print logs of the pod and follow
kubectl delete po foo                 # Delete the pod
```

## Deployment
```bash
kubectl get deployment                    # List deployments
kubectl get deploy bar                    # Show one deployment
kubectl describe deployment bar           # Show details about deployment bar
kubectl scale deployment bar --replicas=4 # Scale deployment to 4 pods
```

## Namespace
```bash
kubectl get ns                                 #List all namespaces
kubectl -n baz get po                      # List pods of namespace baz
kubectl -n baz apply -f resource-file.yaml # Create/update resource from file in namespace baz
```

## Context
```bash
kubectl config view                           # Show kubeconfig settings
KUBECONFIG=~/.kube/config:~/.kube/kubconfig2  # Set variable where to find the kubectl config files
kubectl config get-contexts                   # Display list of contexts
kubectl config current-context                # Display the current-context
kubectl config use-context my-cluster-name    # Set the default context to my-cluster-name
```

## Service
```bash
kubectl get svc                # List services
kubectl get svc bar-svc        # Show one service
kubectl describe svc bar-svc   # Show details about a service
```

## ConfigMap
```bash
kubectl get cm                # List services
kubectl get cm bar-cm        # Show one service
kubectl describe cm bar-cm   # Show details about a service
```