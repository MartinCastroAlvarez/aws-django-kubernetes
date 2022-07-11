#!/bin/bash

clear

source "bin/utils.sh"

source "bin/logo.sh"

source "bin/config.sh"

source "bin/connect.sh"

# loading configuration.
if [ -z "${APPLICATION}" ]
then
    error "Missing application name"
fi
if [ -z "${NAMESPACE}" ]
then
    error "Missing namespace name"
fi

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

# Extracting pods.
POD=$(echo "${PODS}" | grep "${APPLICATION}" | awk '{print $1}' | head -1)
if [ -z "${POD}" ]
then
    error "Failed to find pod for '${APPLICATION}'"
fi

# Running shell in one of the pods.
info "Running shell into '${POD}'"
kubectl exec --stdin --tty "${POD}" -n "${NAMESPACE}" -- /bin/bash
if [ "$?" != "0" ]
then
    error "Failed to run shell in '${NAMESPACE}'"
fi
