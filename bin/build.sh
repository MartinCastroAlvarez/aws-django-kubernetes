#!/bin/bash

# loading configuration.
if [ -z "${IMAGE}" ]
then
    error "Missing Docker image name"
fi
if [ -z "${NAMESPACE}" ]
then
    error "Missing namespace name"
fi
if [ -z "${ACCOUNT}" ]
then
    error "Missing account name"
fi
if [ -z "${AWS_DEFAULT_REGION}" ]
then
    error "Missing region name"
fi

# Detecting architecture.
info "Detecting architecture"
ARCHITECTURE=$(uname -i)
echo "${ARCHITECTURE}"

# Building image.
info "Building '${IMAGE}' Docker image on 'linux/arm64'"
if [ "${ARCHITECTURE}" != "arm64" ]
then
    # Building in x86_64
    docker buildx create --name "arm64builder"
    docker buildx use "arm64builder"
    docker buildx build --platform "linux/arm64" -t "${IMAGE}" --load .
    if [ "$?" != "0" ]
    then
        error "Failed to build '${IMAGE}' Docker image"
    fi

else
    # Building in ARM64
    docker build -t "${IMAGE}" .
    if [ "$?" != "0" ]
    then
        error "Failed to build '${IMAGE}' Docker image"
    fi
fi
