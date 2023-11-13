#!/bin/bash
#
# Creates a Kubernetes cluster on AWS using kops. The state store is saved in S3.
#
kops create cluster \
    --node-count @k8s_node_count@ \
    --zones @k8s_node_zone@ \
    --master-zones @k8s_master_zone@ \
    --dns-zone @k8s_dns_zone@ \
    --node-size @k8s_node_size@ \
    --master-size @k8s_master_size@ \
    --state s3://@aws_state_store_name@ \
    --name @k8s_cluster_name@ \
    --yes


