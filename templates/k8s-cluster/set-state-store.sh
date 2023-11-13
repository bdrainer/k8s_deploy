#!/bin/bash
#
# Sets the state store for the local environment.
#
kops export kubecfg --state s3://@aws_state_store_name@ --name @k8s_cluster_name@