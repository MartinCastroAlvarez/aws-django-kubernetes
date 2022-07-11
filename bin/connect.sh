#!/bin/bash

# loading configuration.
if [ -z "${AWS_DEFAULT_REGION}" ]
then
    AWS_DEFAULT_REGION="us-west-2"
fi
if [ -z "${PROFILE}" ]
then
    PROFILE="default"
fi
if [ -z "${CLUSTER}" ]
then
    error "Missing cluster name"
fi

# Listing existing AWS EKS clusters.
info "Listing AWS EKS clusters"
CLUSTERS="$(
    ./eksctl get cluster \
        --region "${AWS_DEFAULT_REGION}" \
        --profile "${PROFILE}"
)"
echo "${CLUSTERS}"

# Validating if the cluster already exists.
if [ -z "$(echo ${CLUSTERS} | grep "${CLUSTER}")" ]
then
    error "Failed to find '${CLUSTER}'"
fi

# Connecting to the `concntric-app` cluster
info "Connecting to the '${CLUSTER}' AWS EKS cluster"
aws eks update-kubeconfig \
    --profile "${PROFILE}" \
    --region "${AWS_DEFAULT_REGION}" \
    --name "${CLUSTER}"
if [ "$?" != "0" ]
then
    error "Failed to connect to the '${CLUSTER}' AWS EKS cluster"
fi
