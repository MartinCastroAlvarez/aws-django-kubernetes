#!/bin/bash

# This function is used to print INFO messages to STDOUT.
function info {
    tput setaf 3
    echo ""
    echo "$@:"
    printf -vl "%${COLUMNS:-`tput cols 2>&-||echo 80`}s\n" && echo ${l// /-};
    tput sgr0
}

# This function is used to print SUCCESS messages to STDOUT.
function success {
    tput setaf 11
    echo ""
    echo "$@!"
    printf -vl "%${COLUMNS:-`tput cols 2>&-||echo 80`}s\n" && echo ${l// /-};
    tput sgr0
    exit 0
}

# This function is used to print ERROR messages to STDOUT.
function error {
    tput setaf 1
    echo ""
    echo "ERROR: $@!"
    printf -vl "%${COLUMNS:-`tput cols 2>&-||echo 80`}s\n" && echo ${l// /-};
    tput sgr0
    exit 1
}
