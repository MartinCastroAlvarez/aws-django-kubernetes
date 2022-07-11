#!/bin/bash

clear

source "bin/utils.sh"

source "bin/logo.sh"

source "bin/config.sh"

source "bin/connect.sh"

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
if [ -z "${NAMESPACE}" ]
then
    error "Missing namespace name"
fi

# Listing existing AWS EKS naemspaces.
info "Listing AWS EKS namespaces"
NAMESPACES="$(kubectl get namespace)"
if [ "$?" != "0" ]
then
    error "Failed to list namespaces"
fi
echo "${NAMESPACES}"

# Validating if the namespace already exists.
if [ ! -z "$(echo ${NAMESPACES} | grep "${NAMESPACE}" )" ]
then

    # Creating backend node group.
    info "Creating '${NAMESPACE}' AWS EKS namespace"
    kubectl create namespace "${NAMESPACE}"
    if [ "$?" != "0" ]
    then
        error "Failed to create '${NAMESPACE}' AWS EKS namespace"
    fi

fi

success "Environment '${NAMESPACE}' destroyed successfully"
