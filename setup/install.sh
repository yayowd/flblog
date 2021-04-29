#!/usr/bin/env bash

## TEST: Get the directory where the current script is located
#SCRIPT_DIR=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

# Adapt to different operating systems
case "$OSTYPE" in
linux*)
    source /etc/os-release
    case $ID in
    # Arch Linux
    arch)
        #        # TEST
        #        /bin/bash -c "$(cat ${SCRIPT_DIR}/arch.sh)"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yayowd/19blog/main/setup/arch.sh)"
        ;;
    # CentOS Linux
    centos)
        #        # TEST
        #        /bin/bash -c "$(cat ${SCRIPT_DIR}/centos.sh)"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yayowd/19blog/main/setup/centos.sh)"
        ;;
    *)
        echo "your os is not support yet."
        ;;
    esac
    ;;
darwin*)
    #    # TEST
    #    /bin/bash -c "$(cat ${SCRIPT_DIR}/macos.sh)"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yayowd/19blog/main/setup/macos.sh)"
    ;;
*)
    echo "your os is not support yet."
    ;;
esac
