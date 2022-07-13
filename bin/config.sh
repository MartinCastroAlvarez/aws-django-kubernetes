#!/bin/bash

# Parsing arguments from command line.
export PROFILE=$(getopt -o "p:" -l "profile:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export NAMESPACE=$(getopt -o "n:" -l "namespace:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export APPLICATION=$(getopt -o "a:" -l "application:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export CLUSTER=$(getopt -o "c:" -l "cluster:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export TAG_NAME=$(getopt -o "t:" -l "tag:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export NODEGROUP=$(getopt -l "node-group:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export PUBLIC_SUBNETS=$(getopt -l "public-subnets:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export PRIVATE_SUBNETS=$(getopt -l "private-subnets:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")
export PEM_FILE=$(getopt -l "pem-file:" -- $@ 2>/dev/null | awk '{print $2}' | sed "s/'//g")

# Fixed variables.
VARIABLES=(
    # User variables.
    CLUSTER
    PROFILE
    NAMESPACE
    APPLICATION
    TAG_NAME

    # Admin variables.
    NODEGROUP
    PUBLIC_SUBNETS
    PRIVATE_SUBNETS
    PEM_FILE

    # Computed variables.
    IMAGE
    ACCOUNT
    AWS_DEFAULT_REGION
)

# Inferring account from session
ACCOUNT=$(
    aws sts get-caller-identity \
        --profile "${PROFILE}" \
        --query "Account" \
        --output "text"
)

# Inferring the tag name
if [ -z "${TAG_NAME}" ]
then
    TAG_NAME="${NAMESPACE}"
fi

# Inferring the region name.
if [ -z "${AWS_DEFAULT_REGION}" ]
then
    AWS_DEFAULT_REGION=$(aws configure get region --profile "${PROFILE}")
fi

# Computed variables.
IMAGE="${ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${APPLICATION}:${TAG_NAME}"

# Validating configuration.
info "Loading configuration"
for KEY in ${VARIABLES[@]}
do
    VALUE="${!KEY}"
    if [ -z "${VALUE}" ]
    then
        echo " - ${KEY}: ?"
    else
        echo " - ${KEY}: '${VALUE}'"
    fi
done
