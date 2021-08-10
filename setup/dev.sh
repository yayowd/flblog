#!/usr/bin/env bash

msg() {
    printf "%s\n" "$@"
}
tip() {
    msg "[flblog]==> $*"
}
subtip() {
    msg "[flblog]=========> $*"
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

tip "Setup dev environment for flblog..."

initEnv() {
    # Adapt to different operating systems
    case "$OSTYPE" in
    linux*)
        source /etc/os-release
        case $ID in
        # Arch Linux
        arch)
            if ! type nginx || ! type fcgiwrap; then
                abort "Please install flblog first."
            fi
            if ! type git; then
                subtip "Install git"
                sudo pacman --needed --noconfirm -S git
            fi
            server_root=/srv/flblog
            web_user=http
            ;;
        # CentOS Linux
        centos)
            if ! type nginx || ! type fcgiwrap; then
                abort "Please install flblog first."
            fi
            if ! type git; then
                subtip "Install git"
                sudo yum install -y git
            fi
            server_root=/srv/flblog
            web_user=nginx
            ;;
        *)
            abort "your os is not support yet."
            ;;
        esac
        ;;
    darwin*)
        if ! type brew || ! type nginx || ! type fcgiwrap; then
            abort "Please install flblog first."
        fi
        if ! type git; then
            subtip "Install git"
            brew install git
        fi
        server_root=~/srv/flblog
        ;;
    *)
        abort "your os is not support yet."
        ;;
    esac
}

tip "Init environment.."
initEnv

tip "Clone git respository"
git_repository=https://github.com/yayowd/flblog.git
read -e -p "Please enter code work path:" work_path
work_path="$work_path/flblog"
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

if [ -n "$web_user" ]; then
    subtip "Authorize the directory"
    sudo chown -R "${web_user}:${web_user}" ${work_path}
fi

tip "Link server root($server_root) to git working diretory($work_path)"
if [ -d $server_root ]; then
    subtip "Backup current server root directory to *.old"
    sudo mv $server_root $server_root.old
fi
sudo ln -s $work_path $server_root
