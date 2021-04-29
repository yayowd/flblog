#!/usr/bin/env bash

msg() {
    printf "%s\n" "$@"
}
tip() {
    msg "[19BLOG]==> $*"
}
subtip() {
    msg "[19BLOG]=========> $*"
}
abort() {
    subtip "[ERROR]$*"
    subtip "[ERROR]Install aborted."
    exit 1
}

# trap ctrl-c
onInt() {
    abort "Setup cancled by trap"
}
trap onInt INT

tip "Setup dev environment for 19blog..."

initEnv() {
    # Adapt to different operating systems
    case "$OSTYPE" in
    linux*)
        source /etc/os-release
        case $ID in
        # Arch Linux
        arch)
            if ! type nginx || ! type fcgiwrap; then
                abort "Please install 19blog first."
            fi
            if ! type git; then
                subtip "Install git"
                sudo pacman --needed --noconfirm -S git
            fi
            server_root=/srv/19blog
            ;;
        # CentOS Linux
        centos)
            if ! type nginx || ! type fcgiwrap; then
                abort "Please install 19blog first."
            fi
            if ! type git; then
                subtip "Install git"
                sudo yum install -y git
            fi
            server_root=/srv/19blog
            ;;
        *)
            abort "your os is not support yet."
            ;;
        esac
        ;;
    darwin*)
        if ! type brew || ! type nginx || ! type fcgiwrap; then
            abort "Please install 19blog first."
        fi
        if ! type git; then
            subtip "Install git"
            brew install git
        fi
        server_root=~/srv/19blog
        ;;
    *)
        abort "your os is not support yet."
        ;;
    esac
}

tip "Init environment.."
initEnv

tip "Clone git respository"
git_repository=https://github.com/yayowd/19blog.git
read -e -p "Please enter code work path:" work_path
work_path="$work_path/19blog"
if [ -d "$work_path" ]; then
    abort "Code path ($work_path) exists"
fi
if type proxychains; then
    subtip "Using proxy with proxychains"
    cmd_proxy="proxychains -q"
fi
if ! $cmd_proxy git clone $git_repository $work_path; then
    abort "Git clone failed"
fi

tip "Link server root to git working diretory"
if [ -d $server_root ]; then
    subtip "Backup current server root directory to *.old"
    sudo mv $server_root $server_root.old
fi
sudo ln -s $work_path $server_root
