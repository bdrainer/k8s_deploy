#!/bin/bash

./gen

release/set-state-store.sh

kubectl create -f release/k8s-subscriber.yml
kubectl create -f release/k8s-processor.yml
kubectl create -f release/k8s-publisher.yml