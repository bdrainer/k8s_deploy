#!/bin/bash

./gen

release/set-state-store.sh

kubectl replace -f release/k8s-subscriber.yml
kubectl replace -f release/k8s-processor.yml
kubectl replace -f release/k8s-publisher.yml