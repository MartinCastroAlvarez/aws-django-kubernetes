#!/bin/bash


function info {
    tput setaf 3
    echo ""
    echo "$@:"
    printf -vl "%${COLUMNS:-`tput cols 2>&-||echo 80`}s\n" && echo ${l// /-};
    tput sgr0
}

function success {
    tput setaf 11
    echo ""
    echo "$@!"
    printf -vl "%${COLUMNS:-`tput cols 2>&-||echo 80`}s\n" && echo ${l// /-};
    tput sgr0
    exit 0
}

function error {
    tput setaf 1
    echo ""
    echo "ERROR: $@!"
    printf -vl "%${COLUMNS:-`tput cols 2>&-||echo 80`}s\n" && echo ${l// /-};
    tput sgr0
    exit 1
}
