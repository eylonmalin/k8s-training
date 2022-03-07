# Task-11: Expose Lets-Chat on FQDN:80 Using Ingress and Nginx-Controller

***First*** - Create kind cluster with ingress support by :
1. cd day-5/setup 
2. ./setup.sh
3. instructions where taken from: [Setting Up An Ingress Controller](https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx)

In this task we would like to expose Lets-Chat application on port 80 - so we could access the application on http://localhost/lets-chat

1. Add Ingress with rule to Lets-Chat-Web service using **kubectl apply -f web-ingress.yaml**
  * You can use bellow [Specifications Examples](#specifications-examples) to define web-ingress.yaml
  * The host to kubernetes cluster is **localhost**.
  * The path for let-chat app should be `/lets-chat(/|$)(.*)`
  * Add rewrite annotation with target `/$2`
  * Verify you can access the application on http://localhost/lets-chat

  
### Specifications Examples
#### ingress.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
spec:
  rules:
    - host: localhost
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 80
```

#### ingress-with-rewrite-annotation.yaml
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - host: my-host.com
      http:
        paths:
          - path: /relative-path
            pathType: Prefix
            backend:
              service:
                name: my-service
                port:
                  number: 8080
```

