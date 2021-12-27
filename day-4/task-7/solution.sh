#!/bin/bash

source ../../tools/solution_utils.sh

write-app-config-yaml(){
  cat > app-config.yaml <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: lc-app
data:
  settings.yml: |
    env: production
    files:
      enable: true
      provider: local
      local:
        dir: uploads
EOF
  cat app-config.yaml
}

write-app-secret-yaml(){
  cat > app-secret.yaml <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: lc-app
type: Opaque
data:
  secret.key: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURSBSRVFVRVNULS0tLS0NCk1JSUI5VENDQVdBQ0FRQXdnYmd4R1RBWEJnTlZCQW9NRUZGMWIxWmhaR2x6SUV4cGJXbDBaV1F4SERBYUJnTlYNCkJBc01FMFJ2WTNWdFpXNTBJRVJsY0dGeWRHMWxiblF4T1RBM0JnTlZCQU1NTUZkb2VTQmhjbVVnZVc5MUlHUmwNClkyOWthVzVuSUcxbFB5QWdWR2hwY3lCcGN5QnZibXg1SUdFZ2RHVnpkQ0VoSVRFUk1BOEdBMVVFQnd3SVNHRnQNCmFXeDBiMjR4RVRBUEJnTlZCQWdNQ0ZCbGJXSnliMnRsTVFzd0NRWURWUVFHRXdKQ1RURVBNQTBHQ1NxR1NJYjMNCkRRRUpBUllBTUlHZk1BMEdDU3FHU0liM0RRRUJBUVVBQTRHTkFEQ0JpUUtCZ1FDSjlXUmFuRy9mVXZjZktpR2wNCkVMNGFSTGpHdDUzN21aMjhVVTkvM2VpSmVKem5OU091TkxuRitobWFiQXU3SDBMVDRLN0VkcWZGK1hVWlcvMmoNClJLUlljdk9VREdGOUE3T2pXN1VmS2sxSW4zKzZRRENpN1gzNFJFMTYxanFvYUpqcm0vVDE4VE9LY2dra2hSekUNCmFwUW5JRG0wRWEvSFZ6WC9QaVNPR3VlcnR3SURBUUFCTUFzR0NTcUdTSWIzRFFFQkJRT0JnUUJ6TUpkQVY0UVANCkF3ZWw4THpHeDV1TU9zaGV6Ri9LZlA2N3dKOTNVVytON3pYWTZBd1Bnb0xqNEtqdytXdFU2ODRKTDhEdHI5RlgNCm96YWtFKzhwMDZCcHhlZ1I0QlIzRk1IZjZwKzBqUXhVRUFrQXliL21WZ202NlR5Z2hER0M2L1lraUtvWnB0WFENCjk4VHdESUsvMzlXRUIvVjYwN0FzK0tvWWF6UUc4ZHJvcnc9PQ0KLS0tLS1FTkQgQ0VSVElGSUNBVEUgUkVRVUVTVC0tLS0t
EOF

  cat app-secret.yaml
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
case "$1" in
  only-config)
cat >> app-deploy.yaml <<EOF
        volumeMounts:
        - name: settings-config
          mountPath: /usr/src/app/config
      volumes:
        - name: settings-config
          configMap:
            name: lc-app
EOF
    ;;
  config-and-secret)
cat >> app-deploy.yaml <<EOF
        volumeMounts:
        - name: settings-config
          mountPath: /usr/src/app/config
        - name: secret-keys
          mountPath: /usr/src/app/docker
      volumes:
        - name: settings-config
          configMap:
            name: lc-app
        - name: secret-keys
          secret:
            secretName: lc-app
            defaultMode: 256
EOF
    ;;
  projected)
cat >> app-deploy.yaml <<EOF
        volumeMounts:
        - name: settings-config
          mountPath: /usr/src/app/config
      volumes:
        - name: settings-config
          projected:
            defaultMode: 256
            sources:
            - secret:
                name: lc-app
            - configMap:
                name: lc-app

EOF
    ;;
esac
  cat app-deploy.yaml
}

exec-ls-for-app-config-dir(){
  local lc_app_pod_name=$(kubectl get po | grep lc-app | awk '{print $1}')
  printWaitExec kubectl exec -it ${lc_app_pod_name} -- ls -l /usr/src/app/config
}

exec-cat-for-app-config-file(){
  local lc_app_pod_name=$(kubectl get po | grep lc-app | awk '{print $1}')
  printWaitExec kubectl exec -it ${lc_app_pod_name} -- cat /usr/src/app/config/settings.yml
}

create-configmap(){
  printWaitExec kubectl apply -f $1
  printWaitExec kubectl get cm
}

create-secret(){
  printWaitExec kubectl apply -f $1
  printWaitExec kubectl get secret
}

apply-change(){
  echo -n "\$ kubectl apply -f $1"
  read text
  kubectl apply -f $1
}


clear
echo
echo "████████╗  █████╗  ███████╗ ██╗  ██╗     ███████╗     "
echo "╚══██╔══╝ ██╔══██╗ ██╔════╝ ██║ ██╔╝     ╚════██║ ██╗ "
echo "   ██║    ███████║ ███████╗ █████╔╝          ██╔╝ ╚═╝ "
echo "   ██║    ██╔══██║ ╚════██║ ██╔═██╗         ██╔╝  ██╗ "
echo "   ██║    ██║  ██║ ███████║ ██║  ██╗        ██║   ╚═╝ "
echo "   ╚═╝    ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝        ╚═╝       "
echo

echo -e "${RED}Make sure you run this solution after you successfully executed Task 6 solution${NC}"
next
echo -e "${GREEN}Discover app config files${NC}"
echoDashes
exec-ls-for-app-config-dir
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "1. Create ConfigMap in yaml file using **kubectl apply -f app-config.yaml** command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-config.yaml file:${NC}"
echoDashes
write-app-config-yaml
echoDashes
next
echo -e "${GREEN}Create the app ConfigMap:${NC}"
create-configmap app-config.yaml
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "2. Update Lets-Chat-App Deployment to take that ConfigMap as a Volume${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echoDashes
write-app-deploy-yaml only-config
echoDashes
next
echo -e "${GREEN}Update the app Deployment:${NC}"
apply-change app-deploy.yaml
read text
clear
echo -ne "${GREEN}Verify the pods are ready, ${NC}"
get-pods-every-2-sec-until-running lc-app
next
echo -e "${GREEN}Discover app config files again${NC}"
exec-cat-for-app-config-file
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "3. Create Secret in yaml file using **kubectl apply -f app-secret.yaml** command${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-secret.yaml file:${NC}"
echoDashes
write-app-secret-yaml
echoDashes
next
echo -e "${GREEN}Create the app Secret:${NC}"
create-secret app-secret.yaml
next
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "4. Update Lets-Chat-APP Deployment to take that Secret as a Volume${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echoDashes
write-app-deploy-yaml config-and-secret
echoDashes
next
echo -e "${GREEN}Update the App Deployment:${NC}"
apply-change app-deploy.yaml
read text
next
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node
clear
echo -e "${ORANGE}---------------------------------------------------------------------------------------------"
echo -e "5. Now, change Lets-Chat-App Deployment to take the Secret and the ConfigMap as a Volume projected so secret.key and settings.yml will be in same directory${NC}"
echo -n ">>"
read text
echo -e "${GREEN}Writing app-deploy.yaml file:${NC}"
echoDashes
write-app-deploy-yaml projected
echoDashes
next
echo -e "${GREEN}Update the App Deployment:${NC}"
apply-change app-deploy.yaml
read text
next
echo -e "${GREEN}Going to curl the Service on localhost:${NC}"
curl-each-node
clear


