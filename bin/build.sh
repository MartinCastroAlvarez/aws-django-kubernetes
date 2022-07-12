#!/bin/bash

clear

source "bin/utils.sh"

source "bin/logo.sh"

source "bin/config.sh"

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
if [ "${ARCHITECTURE}" != "arm64" ]
then
    info "Building '${IMAGE}' 'linux/arm64' Docker image on '${ARCHITECTURE}'"

    # https://github.com/docker/buildx/issues/495
    docker run --rm --privileged "multiarch/qemu-user-static" --reset -p "yes"

    # Building on `x86_64`.
    docker buildx create --name "arm64builder" --driver "docker-container" --use
    docker buildx build \
        --progress "plain" \
        --platform "linux/arm64" \
        --load \
        --file "Kubernetes" \
        -t "${IMAGE}" \
        .
    if [ "$?" != "0" ]
    then
        error "Failed to build '${IMAGE}' Docker image"
    fi

else
    # Building on `arm64`.
    info "Building '${IMAGE}' 'linux/arm64' Docker image"
    docker build -t "${IMAGE}" --file "Kubernetes" .
    if [ "$?" != "0" ]
    then
        error "Failed to build '${IMAGE}' Docker image"
    fi
fi
