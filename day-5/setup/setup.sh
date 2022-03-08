#!/bin/bash

source ./solution_utils.sh

echo "Going to setup your cluster for k8s-training/day-5"
echoDashes
echo "Going to delete kind cluster"
printWaitExec kind delete cluster
echoDashes

echo "Going to create kind cluster with ingress support"
printWaitExec kind create cluster --config=kind-with-ingress/kind-ingress-config.yaml
echoDashes

echo "Creating ingress-controller"
printWaitExec kubectl apply -f kind-with-ingress/ingress-nginx.yaml
echoDashes

echo "creating lets-chat resources for k8s-training/day-5"
read text

for secret in *-secret.yaml ; do
	printExec kubectl apply -f $secret
done

for config in *-config-map.yaml ; do
	printExec kubectl apply -f $config
done

for svc in *-svc.yaml ; do
	printExec kubectl apply -f $svc
done

for deploy in *-deploy.yaml ; do
	printExec kubectl apply -f $deploy
done

watch kubectl get po
