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

  rm -f web-deploy.yaml
  rm -f svc-deploy.yaml
}

write-web-deploy-yaml(){
  VERSION=$1
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
        version: ${VERSION} # added a second label
    spec:
      containers:
      - name: lc-web # The container name
        image: eylonmalin/lets-chat-web:${VERSION} # The DockerHub image
        ports:
        - containerPort: 80 # Open pod port 80 for the container
        env: # [OPTIONAL] add environments values 
        - name: CODE_ENABLED
          value: "false"
EOF
	cat web-deploy.yaml
}

create-web-deploy(){
  create-deploy web-deploy.yaml
  printWaitExec kubectl rollout history deployment lc-web
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

create-web-svc(){
  create-svc web-svc.yaml
}

get-pods-every-2-sec-until-running(){
  echo -e "${GREEN}Every 2 sec, get pods:${NC}"
  while read pods_status <<< `kubectl get po | grep lc-web | awk '{print $3}'`; [[ $pods_status != "Running Running Running" ]]; do
    printExec kubectl get po -o wide --show-labels
    sleep 2
    echo "-------------------------------------"
  done
  printExec kubectl get po -o wide --show-labels
}



curl-localhost(){
  web_node_port=$(get-web-svc-node-port)
  echo -n "\$ curl --write-out %{http_code} --silent --output /dev/null localhost:$web_node_port/media/favicon.ico"
  read text
  RESULT=$(curl --write-out %{http_code} --silent --output /dev/null localhost:$web_node_port/media/favicon.ico)
  echo $RESULT
  echo "---------------------------------------------------"
}

check-logs-in-pods(){
  for pod in `kubectl get po | grep lc-web | awk '{print $1}'`; do
    printWaitExec kubectl logs $pod
    echo "---------------------------------------------------"
  done
}

apply-web-deploy(){
  printWaitExec kubectl apply -f web-deploy.yaml
  printWaitExec kubectl rollout history deployment lc-web
  sleep 1
}

rollout-undo(){
  printWaitExec kubectl rollout undo deployment lc-web
  printWaitExec kubectl rollout history deployment lc-web
  sleep 1
}

clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗        ██████╗      "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝        ╚════██╗ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝  █████╗  █████╔╝ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗  ╚════╝  ╚═══██╗ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ██████╔╝ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝        ╚═════╝      "
echo

echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Delete the previous Deployment, using kubectl delete deploy command, of Lets-Chat-Web microservice "
echo -e "   and create new Deployment using kubectl apply -f web-deploy.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Cleaning first..................${NC}"
clean
next
echo -e "${GREEN}Writing web-deploy.yaml file:${NC}"
echoDashes
write-web-deploy-yaml v1
echoDashes
next
echo -e "${GREEN}Create the new Deployment:${NC}"
create-web-deploy
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Create a Service to Lets-Chat-Web microservice using kubectl apply -f web-svc.yaml command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing web-svc.yaml file:${NC}"
echoDashes
write-web-svc-yaml
echoDashes
next
echo -e "${GREEN}Create the new Service:${NC}"
create-web-svc
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Verify the pods are ready and you are able to access Lets-Chat-Web UI via browser using node-port${NC}"
echo -n ">>"
read text
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running
next
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-localhost
next
echo -e "${GREEN}Checking the logs of each pod:${NC}"
check-logs-in-pods
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Update the deployment, using kubectl apply -f web-deploy.yaml command, and change the image to "
echo -e "    eylonmalin/lets-chat-web:v2 and also change the label to version: v2 in spec.template.labels${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Changing web-deploy.yaml file:${NC}"
echoDashes
write-web-deploy-yaml v2
echoDashes
next
echo -e "${GREEN}Apply the changed Deployment:${NC}"
apply-web-deploy
next
echo -ne "${GREEN}Verify the update :${NC}"
get-pods-every-2-sec-until-running
next
echo -e "${GREEN}Checking the logs of each pod:${NC}"
check-logs-in-pods
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Rollback to the previous deployment using kubectl rollout undo deployment deploy-name${NC}"
echo -n ">>"
read text
rollout-undo
next
echo -ne "${GREEN}Verify the rollout undo :${NC}"
get-pods-every-2-sec-until-running


