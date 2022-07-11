#!/bin/bash

# Loading `.env` file, if exists.
if [ -f ".env" ]
then
    source .env
fi

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
)

# Computed variables.
IMAGE="${ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${APPLICATION}:${NAMESPACE}"

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
