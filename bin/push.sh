#!/bin/bash

source "bin/build.sh"

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
if [ -z "${ACCOUNT}" ]
then
    error "Missing account name"
fi
if [ -z "${IMAGE}" ]
then
    error "Missing Docker image name"
fi

# Checking if the repository exists.
info "Listing AWS ECR repositories"
REPOSITORIES=$(
    aws ecr describe-repositories \
        --region "${AWS_DEFAULT_REGION}" \
        --profile "${PROFILE}" \
        --repository-names "${APPLICATION}"
)
if [ "$?" != "0" ]
then
    error "Failed list AWS ECR repositories"
fi
echo "${REPOSITORIES}"

# Creating AWS ECR repository, if not exists.
if [ -z "$(echo "${REPOSITORIES}" | jq -r '.repositories[].repositoryName')" ]
then
    info "Creating '${APPLICATION}' AWS ECR repository."
    aws ecr create-repository \
        --region "${AWS_DEFAULT_REGION}" \
        --profile "${PROFILE}" \
        --repository-names "${APPLICATION}"
    if [ "$?" != "0" ]
    then
        error "Failed create AWS ECR repository"
    fi
fi

# Authentication to AWS ECR.
info "Authenticating to AWS ECR"
aws ecr get-login-password \
    --region "${AWS_DEFAULT_REGION}" \
    --profile "${PROFILE}" \
    | docker login \
        --username "AWS" \
        --password-stdin "${ACCOUNT}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
if [ "$?" != "0" ]
then
    error "Failed authenticate to AWS ECR"
fi

# Uploading Docker image to AWS ECR.
info "Pushing '${IMAGE}' to AWS ECR"
docker push "${IMAGE}"
if [ "$?" != "0" ]
then
    error "Failed to push '${IMAGE}' to AWS ECR"
fi

success "Docker image pushed successfully"
