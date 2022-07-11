#!/bin/bash

clear

source "bin/utils.sh"

source "bin/logo.sh"

source "bin/config.sh"

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
if [ -z "${PUBLIC_SUBNETS}" ]
then
    error "Missing public subnets name"
fi
if [ -z "${PRIVATE_SUBNETS}" ]
then
    error "Missing private subnets name"
fi
if [ -z "${NODEGROUP}" ]
then
    error "Missing nodegroup name"
fi
if [ -z "${PEM_FILE}" ]
then
    error "Missing PEM file name"
fi
if [ -z "${NAMESPACE}" ]
then
    error "Missing namespace name"
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

    # Creating a new AWS EKS cluster
    info "Creating a new '${CLUSTER}' AWS EKS cluster"
    ./eksctl create cluster \
        --name "${CLUSTER}" \
        --profile "${PROFILE}" \
        --region "${AWS_DEFAULT_REGION}" \
        --version "1.22" \
        --vpc-public-subnets "${PUBLIC_SUBNETS}" \
        --vpc-private-subnets "${PRIVATE_SUBNETS}" \
        --without-nodegroup
    if [ "$?" != "0" ]
    then
        error "Failed to create '${CLUSTER}' AWS EKS cluster"
    fi

fi

# Listing existing AWS EKS node groups.
info "Listing AWS EKS node groups"
NODEGROUPS="$(
    ./eksctl get nodegroup \
        --profile "${PROFILE}" \
        --region "${AWS_DEFAULT_REGION}" \
        --cluster "${CLUSTER}"
)"
echo "${NODEGROUPS}"

# Validating if the node group already exists.
if [ -z "$(echo ${NODEGROUPS} | grep "${NODEGROUP}" )" ]
then

    # Creating backend node group.
    info "Creating '${NODEGROUP}' AWS EKS Node Group"
    ./eksctl create nodegroup \
      --cluster "${CLUSTER}" \
      --profile "${PROFILE}" \
      --region "${AWS_DEFAULT_REGION}" \
      --skip-outdated-addons-check \
      --name "${NODEGROUP}" \
      --node-type "t4g.medium" \
      --nodes 2 \
      --nodes-min 2 \
      --nodes-max 4 \
      --ssh-access \
      --ssh-public-key "${PEM_FILE}"
    if [ "$?" != "0" ]
    then
        error "Failed to create '${NODEGROUP}' AWS EKS Node Group"
    fi
fi

# Connecting to the cluster.
source "bin/connect.sh"

# Listing existing AWS EKS naemspaces.
info "Listing AWS EKS namespaces"
NAMESPACES="$(kubectl get namespace)"
if [ "$?" != "0" ]
then
    error "Failed to list namespaces"
fi
echo "${NAMESPACES}"

# Validating if the node group already exists.
if [ -z "$(echo ${NAMESPACES} | grep "${NAMESPACE}" )" ]
then

    # Creating backend node group.
    info "Creating '${NAMESPACE}' AWS EKS namespace"
    kubectl create namespace "${NAMESPACE}"
    if [ "$?" != "0" ]
    then
        error "Failed to create '${NAMESPACE}' AWS EKS namespace"
    fi

fi
