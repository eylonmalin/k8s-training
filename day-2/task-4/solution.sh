#!/bin/bash

source ../../tools/solution_utils.sh

clean(){
  local lc_deploy=$(kubectl get deploy | grep lc-web  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_deploy} ]]; then
    printExec kubectl delete deploy ${lc_deploy}
  fi

  local lc_svc=$(kubectl get svc | grep lc-web | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_svc} ]]; then
    printExec kubectl delete svc ${lc_svc}
  fi

  local lc_deploy=$(kubectl get deploy | grep lc-app  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_deploy} ]]; then
    printExec kubectl delete deploy ${lc_deploy}
  fi

  local lc_svc=$(kubectl get svc | grep lc-app | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_svc} ]]; then
    printExec kubectl delete svc ${lc_svc}
  fi

  local lc_deploy=$(kubectl get deploy | grep lc-db  | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_deploy} ]]; then
    printExec kubectl delete deploy ${lc_deploy}
  fi

  local lc_svc=$(kubectl get svc | grep lc-db | awk '{print $1}') >> /dev/null
  if [[ -n ${lc_svc} ]]; then
    printExec kubectl delete svc ${lc_svc}
  fi


  rm -f web-deploy.yaml
  rm -f svc-deploy.yaml
  rm -f app-deploy.yaml
  rm -f app-svc.yaml
  rm -f db-deploy.yaml
  rm -f db-svc.yaml
}

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
        image: mongo:4.4.22 # The DockerHub image
        ports:
        - containerPort: 27017 # Open pod port 27017 for the container
EOF
  cat db-deploy.yaml
}

write-db-svc-yaml(){
  rm -f db-svc.yaml
  cat > db-svc.yaml <<EOF
kind: Service
apiVersion: v1
metadata:
  name: lc-db  # The name of your service
spec:
  selector:
    app: lc-db  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    port: 27017 # The service port
    targetPort: 27017 # The pods port
EOF
  cat db-svc.yaml
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
        - containerPort: 8080 # Open pod port 8080 for the container
        env: # [OPTIONAL] add environments values 
        - name: MONGO_HOST
          value: "lc-db"
        - name: MONGO_PORT
          value: "27017"

EOF
  cat app-deploy.yaml
}

write-app-svc-yaml(){
  rm -f app-svc.yaml
  cat > app-svc.yaml <<EOF
kind: Service
apiVersion: v1
metadata:
  name: lc-app  # The name of your service
spec:
  selector:
    app: lc-app  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    port: 8080 # The service port
    targetPort: 8080 # The pods port
EOF
  cat app-svc.yaml
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
          value: "lc-app"
        - name: APP_PORT
          value: "8080"
EOF
  cat web-deploy.yaml
}

write-web-svc-yaml(){
  rm -f web-svc.yaml
  cat > web-svc.yaml <<EOF
kind: Service
apiVersion: v1
metadata:
  name: lc-web  # The name of your service
spec:
  selector:
    app: lc-web  # defines how the Service finds which Pods to target. Should match labels defined in the Pod template
  ports:
  - protocol: TCP
    nodePort: 31999 # The node port (external)
    port: 80 # The service port
    targetPort: 80 # The pods port
  type: NodePort # [OPTIONAL] If you want ClusterIP you can drop this line 
EOF
  cat web-svc.yaml
}







clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗        ██╗  ██╗     "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ██║  ██║ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗ ███████║ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝ ╚════██║ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗             ██║ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝             ╚═╝     "
echo


echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Create a Deploy and a Service to Lets-Chat-DB microservice"
echo -e "    using kubectl apply -f db-deploy.yaml db-svc.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Cleaning first..................${NC}"
clean
next
echo -e "${GREEN}Writing db-deploy.yaml file:${NC}"
echoDashes
write-db-deploy-yaml
echoDashes
next
echo -e "${GREEN}Create the db Deployment:${NC}"
create-deploy db-deploy.yaml
next
echo -e "${GREEN}Writing db-svc.yaml file:${NC}"
echoDashes
write-db-svc-yaml
echoDashes
next
echo -e "${GREEN}Create the db Service:${NC}"
create-svc db-svc.yaml
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-db
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Create a Deploy and a Service to Lets-Chat-APP microservice "
echo -e "    using kubectl apply -f app-deploy.yaml app-svc.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echoDashes
write-app-deploy-yaml
echoDashes
next
echo -e "${GREEN}Create the app Deployment:${NC}"
create-deploy app-deploy.yaml
next
echo -e "${GREEN}Writing app-svc.yaml file:${NC}"
echoDashes
write-app-svc-yaml
echoDashes
next
echo -e "${GREEN}Create the app Service:${NC}"
create-svc app-svc.yaml
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-app
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Update the previous Deploy of Lets-Chat-Web to "
echo -e "    connect to Lets-Chat-App service using kubectl apply -f web-deploy.yaml${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echoDashes
write-web-deploy-yaml
echoDashes
next
echo -e "${GREEN}Create the web Deployment:${NC}"
create-deploy web-deploy.yaml
next
echo -e "${GREEN}Writing web-svc.yaml file:${NC}"
echoDashes
write-web-svc-yaml
echoDashes
next
echo -e "${GREEN}Create the web Service:${NC}"
create-svc web-svc.yaml
next
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-web 3
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Open the service on the Node Port and access the login page.${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node
