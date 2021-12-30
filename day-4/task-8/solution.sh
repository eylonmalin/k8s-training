#!/bin/bash

source ../../tools/solution_utils.sh

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
        volumeMounts:
        - name: web-log
          mountPath: /var/log/nginx/letschat
      - name: lc-logrotate # The container name
        image: blacklabelops/logrotate # The DockerHub image
        env:
        - name: LOGS_DIRECTORIES
          value: /var/logs/lets-chat
        - name: LOGROTATE_SIZE
          value: "10k"
        - name: LOGROTATE_CRONSCHEDULE
          value: "* * * * * *"
        volumeMounts:
        - name: web-log
          mountPath: /var/logs/lets-chat

      volumes:
      - name: web-log
        emptyDir: {}
EOF
  cat web-deploy.yaml
}


clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗      █████╗      "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝     ██╔══██╗ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝      ╚█████╔╝ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗      ██╔══██╗ ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗     ╚█████╔╝ ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝      ╚════╝      "
echo

echo -e "${RED}Make sure you run this solution after you successfully executed Task 7 solution${NC}"
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Add another container to Lets-Chat-Web Pod. The second conatiner will be "
echo -e "   responsible to logrotate the log file of Lets-Chat-Web.${NC}"
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
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node
