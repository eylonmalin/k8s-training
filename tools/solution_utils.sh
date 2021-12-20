#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

printWaitExec() {
  echo -n "\$ $*"
  read text
  eval "$@"
}

printExec() {
  echo "\$ $*"
  echo -n
  eval "$@"
}

next() {
  echo -n "Next >>"
  read text
  clear
}

echoDashes() {
  echo "----------------------------------------------"
}

create-deploy(){
  printWaitExec kubectl apply -f $1
  printWaitExec kubectl get deploy
}

create-svc(){
  printWaitExec kubectl apply -f $1
  printWaitExec kubectl get svc
}

get-pods-every-2-sec-until-running(){
  echo -e "${GREEN}Every 2 sec, get pods:${NC}"

  if [[ $2 -eq 3 ]]; then
    pods_running_status="Running Running Running"
  else
    pods_running_status="Running"
  fi

  while read pods_status <<< `kubectl get po | grep $1 | awk '{print $3}'`; [[ "$pods_status" != "$pods_running_status" ]]; do
    printExec kubectl get po -o wide --show-labels | grep $1
    sleep 2
    echoDashes
  done
  printExec kubectl get po -o wide --show-labels | grep $1
}

curl-each-node(){
  web_node_port=$(get-web-svc-node-port)
  echo -n "\$ curl --write-out %{http_code} --silent --output /dev/null localhost:$web_node_port/login"
  read text
  RESULT=$(curl --write-out %{http_code} --silent --output /dev/null localhost:$web_node_port/login)
  echo $RESULT
  echoDashes
}

get-web-svc-node-port(){
  WEB_SVC_PORT=$(kubectl get svc | grep lc-web |awk '{print $5}')
  read web_svc_cluster_port web_node_port <<< ${WEB_SVC_PORT//[:]/ }
  cut -d'/' -f1 <<< $web_node_port
}