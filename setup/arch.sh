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

tip "Setup 19blog on archlinux..."

tip "Checking for bash version.."
if [[ ${BASH_VERSION:0:1} -lt 4 ]]; then
    subtip "The bash version ($BASH_VERSION) is not 4.0+"
    subtip "Try to update bash"
    sudo pacman --needed --noconfirm -q -S bash
    abort "Open a new terminal window and try again"
fi

tip "Configuration.."
read -e -r -p "Enter server path [/srv]: " server_path
server_path=${server_path%/}
server_path=${server_path:-/srv}
server_root=${server_path}/19blog
if [ -d "$server_root" ]; then
    abort "Server root path ($server_root) exists"
fi
read -e -r -p "Enter password for administrator: " admin_passwd
if [ -z "$admin_passwd" ]; then
    abort "Password for administrator can not be empty"
fi
read -e -r -p "Enter you domain: " server_name
if [ -z "$server_name" ]; then
    abort "Domain cannot be empty"
fi

tip "Install web server.."
sudo pacman --needed --noconfirm -q -S nginx fcgiwrap
subtip "Start fastcgiwrap"
sudo systemctl enable fcgiwrap.socket
sudo systemctl stop fcgiwrap.service
sudo systemctl stop fcgiwrap.socket
sudo systemctl start fcgiwrap.socket
subtip "Find unix socket path of fastcgiwrap"
socket_path=$(sudo systemctl status fcgiwrap.socket | grep Listen:)
socket_path=${socket_path#*Listen: }
socket_path=${socket_path% *}
if [ -z "$socket_path" ]; then
    abort "Can not found socket path of fastcgiwrap"
fi

tip "Get files.."
subtip "Prepare directory"
sudo mkdir -p "$server_path"
subtip "Install file tools"
sudo pacman --needed --noconfirm -q -S wget unzip
subtip "Download project package"
package_file=$(mktemp)
package_version="0.1.0"
package_url="https://github.com/yayowd/19blog/releases/download/v$package_version/19blog-$package_version.zip"
if ! wget -q "$package_url" -O "$package_file"; then
    abort "Download package file failed"
fi
subtip "Unzip package file"
package_dir="/tmp/19blog"
mkdir "$package_dir"
if ! unzip -q -o "$package_file" -d "$package_dir"; then
    abort "Unzip package file failed"
fi
subtip "Copy files"
if ! sudo mv -T "$package_dir" "$server_root"; then
    abort "Copy files to server root failed"
fi
config_root=$server_root/config
blogs_root=$server_root/blogs
dist_root=$server_root/dist
cgi_root=$server_root/cgi
sudo mkdir -p "$config_root"
sudo chown -R http:http "$server_root"

tip "Web basic authorization"
subtip "Install web tools"
sudo pacman --needed --noconfirm -q -S apache
subtip "Create account for administrator"
sudo -u http touch "${config_root}/.passwd_admin"
sudo -u http touch "${config_root}/.passwd_manage"
sudo -u http htpasswd -b "${config_root}/.passwd_admin" admin "$admin_passwd"
subtip "administrator account: for admin  -> name is admin, passwd is $admin_passwd"

tip "Config nginx"
log_path=/var/log/nginx
read -d '' config <<-EOF
# for 19blog
server {
   listen          80;
   listen          [::]:80;
   server_name     $server_name;
   access_log      $log_path/19blog.access.log;
   error_log       $log_path/19blog.error.log;
   location / {
       root        $blogs_root;
       try_files   \$uri \$uri.html \$uri/ @dist;
   }
   location @dist {
       root        $dist_root;
       try_files   \$uri \$uri/ =404;
   }
   location ~ /api/ {
       root                    $cgi_root;
       # buffer settings
       gzip                    off;
       client_max_body_size    0;
       fastcgi_buffer_size     32k;
       fastcgi_buffers         32 32k;
       # fastcgi settings
       include                 fastcgi.conf;
       fastcgi_param           REMOTE_USER \$remote_user;
       fastcgi_param           PATH_INFO \$1;
       fastcgi_pass            unix:$socket_path;
   }
   rewrite ^/admin$ /admin/index permanent;
   rewrite ^/admin/$ /admin/index permanent;
   location ~ /admin/ {
       root                    $cgi_root;
       # basic authorization
       auth_basic              "19blog admin login";
       auth_basic_user_file    $config_root/.passwd_admin;
       # buffer settings
       gzip                    off;
       client_max_body_size    0;
       fastcgi_buffer_size     32k;
       fastcgi_buffers         32 32k;
       # fastcgi settings
       include                 fastcgi.conf;
       fastcgi_param           REMOTE_USER \$remote_user;
       fastcgi_param           PATH_INFO \$1;
       fastcgi_pass            unix:$socket_path;
   }
   rewrite ^/manage$ /manage/index permanent;
   rewrite ^/manage/$ /manage/index permanent;
   location ~ /manage/ {
       root                    $cgi_root;
       # basic authorization
       auth_basic              "19blog manage login";
       auth_basic_user_file    $config_root/.passwd_manage;
       # buffer settings
       gzip                    off;
       client_max_body_size    0;
       fastcgi_buffer_size     32k;
       fastcgi_buffers         32 32k;
       # fastcgi settings
       include                 fastcgi.conf;
       fastcgi_param           REMOTE_USER \$remote_user;
       fastcgi_param           PATH_INFO \$1;
       fastcgi_pass            unix:$socket_path;
   }
}
EOF
sudo tee /etc/nginx/19blog.conf <<<"$config" >/dev/null
sudo sed -i '/# for 19blog/,+2d' /etc/nginx/nginx.conf
sudo sed -i '/[[:space:]]\+server {/i # for 19blog\ninclude 19blog.conf;\n' /etc/nginx/nginx.conf

tip "Start nginx"
sudo systemctl enable nginx
sudo systemctl stop nginx
sudo systemctl start nginx

tip "Testing"
subtip "http://$server_name/admin     -> Use administartor account to login, config home page and registe new user"
subtip "http://$server_name/          -> Your home page"
subtip "NOTE:"
subtip "  When error '502 Bad Gateway' occurs, restart fcgiwrap service by:"
subtip "  sudo systemctl stop fcgiwrap.service"
subtip "  sudo systemctl stop fcgiwrap.socket"
subtip "  sudo systemctl start fcgiwrap.socket"
