#!/bin/bash

source ../../tools/solution_utils.sh

write-db-deploy-yaml(){
  rm -f db-deploy.yaml
  cat > db-deploy.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-db # The name of your deployment
  labels:
    app: lc-db  # The label of your deployment
spec:
  replicas: 1 # Number of replicated pods
  selector:
    matchLabels:
      app: lc-db # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: lc-db # The label of the pod to match selectors
    spec:
      containers:
      - name: lc-db # The container name
        image: mongo # The DockerHub image
        ports:
        - containerPort: 27017 # Open pod port 80 for the container
        livenessProbe:
          exec:
            command:
            - mongo
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 30
          timeoutSeconds: 5
        readinessProbe:
          exec:
            command:
            - mongo
            - --eval
            - "db.adminCommand('ping')"
          initialDelaySeconds: 5
          timeoutSeconds: 1
EOF
  cat db-deploy.yaml
}

write-app-deploy-yaml(){
  rm -f app-deploy.yaml
  cat > app-deploy.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-app # The name of your deployment
  labels:
    app: lc-app  # The label of your deployment
spec:
  replicas: 1 # Number of replicated pods
  selector:
    matchLabels:
      app: lc-app # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: lc-app # The label of the pod to match selectors
    spec:
      containers:
      - name: lc-app # The container name
        image: eylonmalin/lets-chat-app:v1 # The DockerHub image
        ports:
        - containerPort: 8080 # Open pod port 80 for the container
        livenessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /login
            port: 8080
          initialDelaySeconds: 5
          periodSeconds: 1
        env: # [OPTIONAL] add environments values 
        - name: MONGO_HOST
          value: lc-db
        - name: MONGO_PORT
          value: "27017"
EOF
  cat app-deploy.yaml
}

write-web-deploy-yaml(){
  rm -f web-deploy.yaml
  cat > web-deploy.yaml <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: lc-web # The name of your deployment
  labels:
    app: lc-web  # The label of your deployment
spec:
  replicas: 3 # Number of replicated pods
  selector:
    matchLabels:
      app: lc-web # defines how the Deployment finds which Pods to manage. Should match labels defined in the Pod template
  template:
    metadata:
      labels:
        app: lc-web # The label of the pod to match selectors
    spec:
      containers:
      - name: lc-web # The container name
        image: eylonmalin/lets-chat-web:v1 # The DockerHub image
        ports:
        - containerPort: 80 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: CODE_ENABLED
          value: "false"
        - name: APP_HOST
          value: lc-app
        - name: APP_PORT
          value: "8080"
        livenessProbe:
          httpGet:
            path: /media/favicon.ico
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /media/favicon.ico
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 1
EOF
  cat web-deploy.yaml
}

create-health-problem-in-lc-app-pod(){
  local lc_app_pod_name=$(kubectl get po | grep lc-app | awk '{print $1}')
  printWaitExec kubectl exec -it ${lc_app_pod_name} -- rm -rf media
}

watch-endpoints-and-pods() {
  while read endpoint_status <<< `kubectl get endpoints | grep lc-app | awk '{print NF}'`; [[ "$endpoint_status" != "3" ]]; do
    printExec kubectl get endpoints
    echoDashes
    printExec kubectl get po -o wide --show-labels
    echoDashes
    sleep 2
  done
  printExec kubectl get endpoints
  echoDashes
  printExec kubectl get po -o wide --show-labels
  echoDashes
}


clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗        ███████╗     "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ██╔════╝ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗ ███████╗ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝ ╚════██║ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ███████║ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝        ╚══════╝     "
echo

echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Add Liveness and Readiness Probes to Lets-Chat-APP yaml file and "
echo -e "    update with kubectl apply -f app-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echoDashes
write-app-deploy-yaml
echoDashes
next
echo -e "${GREEN}Update the app Deployment:${NC}"
apply-change app-deploy.yaml
read text
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Add Liveness and Readiness Probes to Lets-Chat-DB yaml file and "
echo -e "    update with kubectl apply -f db-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing db-deploy.yaml file:${NC}"
echoDashes
write-db-deploy-yaml
echoDashes
next
echo -e "${GREEN}Update the db Deployment:${NC}"
apply-change db-deploy.yaml
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-app
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Add Liveness and Readiness Probes to Lets-Chat-Web yaml file and "
echo -e "    update with kubectl apply -f web-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echoDashes
write-web-deploy-yaml
echoDashes
read text
echo -e "${GREEN}Update the web Deployment:${NC}"
apply-change web-deploy.yaml
read text
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-web 3
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Create a health problem in one of the Lets-Chat-App pods and verify it is removed from the Service endpoints.${NC}"
echo -n ">>"
read text
create-health-problem-in-lc-app-pod
next
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node
echo -e "5. Watch endpoint state and pod status ${NC}"
watch-endpoints-and-pods
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node