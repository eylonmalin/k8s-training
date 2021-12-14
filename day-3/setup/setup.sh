#!/bin/bash

echo "Going to setup cluster for k8s-training/day-3"
for svc in *-svc.yaml ; do
	kubectl apply -f $svc
done

for deploy in *-deploy.yaml ; do
	kubectl apply -f $deploy
done

watch kubectl get po

