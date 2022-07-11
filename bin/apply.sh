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
if [ -z "${APPLICATION}" ]
then
    error "Missing application name"
fi
if [ -z "${NAMESPACE}" ]
then
    error "Missing namespace name"
fi

# Checking if config file exists.
SECRETS_FILE="${APPLICATION}-${NAMESPACE}-config.sh"
info "Loading '${SECRETS_FILE}'"
if [ ! -f "${SECRETS_FILE}" ]
then
    error "Not found: '${SECRETS_FILE}'"
fi

# Generating `kustomization.yaml`
info "Deploying '${APPLICATION}-${NAMESPACE}' secrets"
kubectl create secret generic "config" \
    --from-env-file="${SECRETS_FILE}" \
    --save-config \
    --dry-run="client" \
    -o "yaml" | kubectl apply -f - --namespace "${NAMESPACE}"
if [ "$?" != "0" ]
then
    error "Failed to deploy '${APPLICATION}-${NAMESPACE}-config' secrets"
fi

# Validating that the configuration exists.
info "Validating application configuration"
CONFIG=$(kubectl get secret "config" -n "${NAMESPACE}")
if [ "$?" != "0" ]
then
    error "Failed to load configuration"
fi
echo "${CONFIG}"

# Validating configuration status.
if [ -z "$(echo "${CONFIG}" | grep -w "config")" ]
then
    error "Failed to find application configuration"
fi

# Checking if config file exists.
APPLICATION_FILE="${APPLICATION}.yaml"
info "Loading '${APPLICATION_FILE}'"
if [ ! -f "${APPLICATION_FILE}" ]
then
    error "Not found: '${APPLICATION_FILE}'"
fi
cat "${APPLICATION_FILE}"

# Deploying application to Kubernetes
info "Deploying '${APPLICATION}' to '${NAMESPACE}'"
cat "${APPLICATION_FILE}" \
    | sed "s/TAG_NAME/${TAG_NAME}/" \
    | kubectl apply -f - --namespace "${NAMESPACE}"
if [ "$?" != "0" ]
then
    error "Failed to deploy '${APPLICATION}' into AWS EKS"
fi

# Checking if deployment exists.
info "Loading deployments"
DEPLOYMENTS=$(kubectl get deployments -n "${NAMESPACE}")
if [ "$?" != "0" ]
then
    error "Failed to load deployments"
fi
echo "${DEPLOYMENTS}"

# Validating deployment status.
if [ -z "$(echo "${DEPLOYMENTS}" | grep "${APPLICATION}")" ]
then
    error "Failed to deploy '${APPLICATION}'"
fi

# Forcing the pod to pull the latest image.
info "Forcing a rollout on '${APPLICATION}' at '${NAMESPACE}'"
# kubectl rollout restart "deployment.apps/${APPLICATION}" -n "${NAMESPACE}"
kubectl patch deployment \
    -p '{
        "spec": {
            "template": {
                "metadata": {
                    "annotations": {
                        "last_deploy_date": "'"`date`"'"
                    }
                }
            }
        }
    }' \
    -n "${NAMESPACE}" \
    "${APPLICATION}" 
if [ "$?" != "0" ]
then
    error "Failed to restart '${APPLICATION}'"
fi

# Checking if config file exists.
LOAD_BALANCER_FILE="${APPLICATION}-elb.yaml"
info "Loading '${LOAD_BALANCER_FILE}'"
if [ ! -f "${LOAD_BALANCER_FILE}" ]
then
    error "Not found: '${LOAD_BALANCER_FILE}'"
fi
cat "${LOAD_BALANCER_FILE}"

# Deploying ELB services to Kubernetes
info "Deploying '${APPLICATION}' ELB to '${NAMESPACE}'"
kubectl apply \
    --namespace "${NAMESPACE}" \
    -f "${LOAD_BALANCER_FILE}"
if [ "$?" != "0" ]
then
    error "Failed to deploy '${APPLICATION}-elb' into AWS EKS"
fi

# Checking if service exists.
info "Loading services"
SERVICES=$(kubectl get svc -n "${NAMESPACE}")
if [ "$?" != "0" ]
then
    error "Failed to load services"
fi
echo "${SERVICES}"

# Validating deployment status.
if [ -z "$(echo "${SERVICES}" | grep "${APPLICATION}-elb")" ]
then
    error "Failed to deploy '${APPLICATION}-elb'"
fi

success "Configuration applied successfully to '${APPLICATION}' on '${NAMESPACE}'"
