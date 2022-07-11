#!/bin/bash

clear

source "bin/utils.sh"

source "bin/logo.sh"

source "bin/config.sh"

# Adding current directory to the PATH variable.
info "Updating 'PATH' to include the current directory"
export PATH="${PATH}:."
echo "${PATH}"

# Checking if the `kubectl` CLI exists.
if [ -z "$(kubectl --help)" ]
then
    # Download `kubectl`
    info "Downloading 'kubectl' installer"
    latest="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
    curl -LO "https://dl.k8s.io/release/${latest}/bin/linux/amd64/kubectl"
    if [ "$?" != "0" ]
    then
        error "Failed to download 'kubectl'"
    fi

    # Downloading `kubectl` checksum.
    info "Downloading 'kubectl' checksum"
    RELEASE="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
    curl -LO "https://dl.k8s.io/${RELEASE}/bin/linux/amd64/kubectl.sha256"
    if [ "$?" != "0" ]
    then
        error "Failed to download 'kubectl' checksum"
    fi

    # Verifying `kubectl` installer.
    info "Running SHA256 checksum on the 'kubectl' installer"
    echo "$(cat kubectl.sha256) kubectl" | sha256sum --check
    if [ "$?" != "0" ]
    then
        error "Checksum verification failed"
    fi

    # Installing `kubectl`.
    info "Installing 'kubectl'"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    if [ "$?" != "0" ]
    then
        error "Failed to install 'kubectl'."
    fi

fi

# Checking if the `eksctl` CLI exists.
if [ ! -f "./eksctl" ]
then
    info "Installing 'eksctl'"
    curl \
        --silent \
        --location \
        "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" \
        | tar xz -C .
    if [ "$?" != "0" ]
    then
        error "Failed to install 'eksctl'"
    fi
fi

# Changing permissions on `eksctl`.
if [ ! -x "./eksctl" ]
then
    info "Adding permissions to 'eksctl'"
    chmod o+x ./eksctl
    if [ "$?" != "0" ]
    then
        error "Failed to add permissions to 'eksctl'"
    fi
fi

# Changing permissions on `kubectl`.
if [ ! -x "/usr/local/bin/kubectl" ]
then
    info "Adding permissions to 'kubectl'"
    sudo chmod o+x /usr/local/bin/kubectl
    if [ "$?" != "0" ]
    then
        error "Failed to add permissions to 'kubectl'"
    fi
fi
