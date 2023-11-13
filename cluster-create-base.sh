#!/bin/bash

./gen

release/set-state-store.sh

kubectl create -f release/k8s-nginx-ingress.yml

kubectl create -f release/k8s-cluster-autoscaler.yml
