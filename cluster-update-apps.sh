#!/bin/bash
#
# If you have a lot of applications being replaced consider sleeping in between replacing one or more services.
# We had ~10 apps to deploy.  Replacing them all at once was problematic as Kubernetes keeps the current version
# of the service running while trying to bring up the new version.  If you replace everything all at once you
# will be running roughly double the number of pods.  This could cause errors and it was something we ran into.
# We added sleep calls in between some of the 'kubectl replace' commands.
#

./gen

release/set-state-store.sh

echo 'updating subscriber'
kubectl replace -f release/k8s-subscriber.yml

#echo 'sleeping 60 seconds...'
#sleep 60
echo 'updating processor'
kubectl replace -f release/k8s-processor.yml

#echo 'sleeping 60 seconds...'
#sleep 60
echo 'updating publisher'
kubectl replace -f release/k8s-publisher.yml