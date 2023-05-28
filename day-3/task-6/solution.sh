#!/bin/bash

source ../../tools/solution_utils.sh

clean(){
  local lc_config=$(kubectl get cm | grep lc-config  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_config} ]]; then
    printExec kubectl delete cm ${lc_config}
  fi

  local lc_secret=$(kubectl get secret | grep lc-db | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_secret} ]]; then
    printExec kubectl delete secret ${lc_secret}
  fi

}


write-db-secret-yaml(){
  echo "admin | base64"
  echo -n "admin" | base64
  echo "1f2d1e2e67df | base64"
  echo -n "1f2d1e2e67df" | base64
  echoDashes

  cat > db-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: lc-db
type: Opaque
data:
  username: $(echo -n "admin" | base64)
  password: $(echo -n "1f2d1e2e67df" | base64)
EOF

  cat db-secret.yaml
}

write-lc-config-yaml(){
  cat > lc-config.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: lc-config
data:
  code.enabled: "false"
EOF
  cat lc-config.yaml
}

write-db-deploy-yaml(){
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
        image: mongo:4.4.22# The DockerHub image
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
        env: # [OPTIONAL] add environments values 
        - name: MONGO_INITDB_ROOT_USERNAME
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: username
        - name: MONGO_INITDB_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: password
EOF

  cat db-deploy.yaml
}

write-app-deploy-yaml(){
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
        - name: MONGO_USER
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: username
        - name: MONGO_PASS
          valueFrom:
            secretKeyRef:
              name: lc-db
              key: password
EOF
  cat app-deploy.yaml
}

write-web-deploy-yaml(){
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
        env: # [OPTIONAL] add environments values 
        - name: CODE_ENABLED
          valueFrom:
            configMapKeyRef:
              name: lc-config
              key: code.enabled
        - name: APP_HOST
          value: lc-app
        - name: APP_PORT
          value: "8080"

EOF
  cat web-deploy.yaml
}

create-configmap(){
  printWaitExec kubectl apply -f $1
  printWaitExec kubectl get cm
  printWaitExec kubectl describe cm lc-config
}

create-secret(){
  printWaitExec kubectl apply -f $1
  printWaitExec kubectl get secret
  printWaitExec kubectl describe secret lc-db
}


clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗         ██████╗      "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ██╔════╝  ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗ ███████╗  ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝ ██╔═══██╗ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ╚██████╔╝ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝         ╚═════╝      "
echo

echo -e "${RED}Make sure you run this solution after you successfully executed Task 5 solution${NC}"
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Create ConfigMap in yaml file using **kubectl apply -f lc-config.yaml** command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing lc-config.yaml file:${NC}"
echoDashes
write-lc-config-yaml
echoDashes
next
echo -e "${GREEN}Create the lets-chat ConfigMap:${NC}"
create-configmap lc-config.yaml
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Update Lets-Chat-Web Deployment to take the value of **CODE_ENABLED** from the ConfigMap${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echoDashes
write-web-deploy-yaml
echoDashes
next
echo -e "${GREEN}Update the web Deployment:${NC}"
apply-change web-deploy.yaml
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-web 3
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Create Secret in yaml file using kubectl apply -f db-secret.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing db-secret.yaml file:${NC}"
echoDashes
write-db-secret-yaml
echoDashes
next
echo -e "${GREEN}Create the db Secret:${NC}"
create-secret db-secret.yaml
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Update Lets-Chat-DB and Lets-Chat-APP Deployments to take the values from the Secret${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing db-deploy.yaml file:${NC}"
echoDashes
write-db-deploy-yaml "WITH_SECRET"
echoDashes
next
echo -e "${GREEN}Update the DB Deployment:${NC}"
apply-change db-deploy.yaml
read text
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-db 1
next
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echoDashes
write-app-deploy-yaml "WITH_SECRET"
echoDashes
next
echo -e "${GREEN}Update the App Deployment:${NC}"
apply-change app-deploy.yaml
read text
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-app 1
next
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node


