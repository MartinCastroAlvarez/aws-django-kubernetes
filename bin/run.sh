#!/bin/bash

source "bin/build.sh" $@

# loading configuration.
if [ -z "${IMAGE}" ]
then
    error "Missing Docker image name"
fi
if [ -z "${ACCOUNT}" ]
then
    error "Missing account name"
fi
if [ -z "${AWS_DEFAULT_REGION}" ]
then
    error "Missing region name"
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

# Running container locally.
info "Starting application on 'http://0.0.0.0:80'"
docker run -p "80:8000" --env-file "${SECRETS_FILE}" "${IMAGE}"
if [ "$?" != "0" ]
then
    error "Failed to start Docker container"
fi

success "Docker container started successfully"
