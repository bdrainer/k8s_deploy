#!/bin/bash

./gen

release/set-state-store.sh

echo 'creating subscriber'
kubectl create -f release/k8s-subscriber.yml

echo 'creating processor'
kubectl create -f release/k8s-processor.yml

echo 'creating publisher'
kubectl create -f release/k8s-publisher.yml