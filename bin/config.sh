#!/bin/bash

# Fixed variables.
VARIABLES=(
    CLUSTER
    PROFILE
    AWS_DEFAULT_REGION
    PUBLIC_SUBNETS
    PRIVATE_SUBNETS
    APPLICATION
    NODEGROUP
    PEM_FILE
    ACCOUNT
    NAMESPACE
    IMAGE
    TAG_NAME
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
echo $AWS_DEFAULT_REGION

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
