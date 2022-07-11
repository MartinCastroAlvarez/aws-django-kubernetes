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
if [ -z "${APPLICATION}" ]
then
    error "Missing application name"
fi
if [ -z "${NAMESPACE}" ]
then
    error "Missing namespace name"
fi

# Listing cluster namespaces.
info "Listing AWS EKS namespaces"
NAMESPACES=$(kubectl get svc --all-namespaces)
echo "${NAMESPACES}"

# Listing cluster nodes.
info "Listing AWS EKS nodes"
NODES=$(kubectl get nodes --show-labels)
echo "${NODES}"

# Loading application status.
info "Loading '${APPLICATION}' application status"
PODS=$(
    kubectl get pods \
        -n "${NAMESPACE}" \
        -l "app=${APPLICATION}" \
        --show-labels
)
if [ "$?" != "0" ]
then
    error "Failed to get '${APPLICATION}' status"
fi
echo "${PODS}"

# Getting the status of each pod, individually.
for POD in $(echo "${PODS}" | tail -n +2 | awk '{print $1}')
do
    # Getting pod health report
    info "Describing '${POD}' pod"
    kubectl describe pod "${POD}" --namespace "${NAMESPACE}"
    if [ "$?" != "0" ]
    then
        error "Failed to describe '${POD}' pod"
    fi

    # Fetching logs from pod.
    info "Fetching '${POD}' pod logs"
    kubectl logs \
        --tail 20 \
        --namespace "${NAMESPACE}" \
        "${POD}"
    kubectl logs \
        --previous \
        --tail 20 \
        --namespace "${NAMESPACE}" \
        "${POD}"
done 

# Detecting failing Pods
info "Detecting failing pods"
ERRORS="$(echo "${PODS}" | egrep "CrashLoopBackOff|Error")" 
if [ ! -z "${ERRORS}" ]
then
    echo "${ERRORS}"
    error "Pods are failing"
fi
echo "No pods failing!"

# Loading ELB status.
info "Loading '${APPLICATION}-elb' port on '${NAMESPACE} '"
SERVICES=$(
    kubectl get svc \
        --namespace "${NAMESPACE}" \
        "${APPLICATION}-elb" 
)
if [ "$?" != "0" ]
then
    error "Failed to load 'service/${APPLICATION}-elb'"
fi
echo "${SERVICES}"

# Fetching ELB URL.
info "Loading '${APPLICATION}-elb' URL"
URL="$(echo "${SERVICES}" | grep "${APPLICATION}" | awk '{print $4}')"
if [ "$?" != "0" ]
then
    error "Failed to get '${APPLICATION}-elb' URL"
fi
echo "${URL}"

# Checking application health
info "Getting '${APPLICATION}-elb' health status on port 80"
curl -k -s -i -X GET "https://${URL}" | head -20
if [ "$?" != "0" ]
then
    error "Failed to get '${APPLICATION}-elb' health status"
fi

success "Health check passed for '${APPLICATION}' on '${NAMESPACE}': 'https://${URL}'"
