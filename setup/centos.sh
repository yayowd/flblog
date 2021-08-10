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

tip "Setup flblog on centos..."

tip "Checking for bash version.."
if [[ ${BASH_VERSION:0:1} -lt 4 ]]; then
    subtip "The bash version ($BASH_VERSION) is not 4.0+"
    subtip "Try to update bash"
    sudo yum install -y bash
    abort "Open a new terminal window and try again"
fi

tip "Configuration.."
read -e -r -p "Enter server path [/srv]: " server_path
server_path=${server_path%/}
server_path=${server_path:-/srv}
server_root=${server_path}/flblog
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
sudo yum install -y nginx
subtip "Install fcgiwrap from EPEL"
sudo yum install -y epel-release
sudo yum --enablerepo=epel install -y fcgiwrap
subtip "Start fastcgiwrap"
sudo systemctl enable fcgiwrap@nginx.socket
sudo systemctl stop fcgiwrap@nginx.service
sudo systemctl stop fcgiwrap@nginx.socket
sudo systemctl start fcgiwrap@nginx.socket
subtip "Find unix socket path of fastcgiwrap"
socket_path=$(sudo systemctl status fcgiwrap@nginx.socket | grep Listen:)
socket_path=${socket_path#*Listen: }
socket_path=${socket_path% *}
if [ -z "$socket_path" ]; then
    abort "Can not found socket path of fastcgiwrap"
fi

tip "Get files.."
subtip "Prepare directory"
sudo mkdir -p "$server_path"
subtip "Install file tools"
sudo yum install -y wget unzip
subtip "Download project package"
package_file=$(mktemp)
package_version="0.1.0"
package_url="https://github.com/yayowd/flblog/releases/download/v$package_version/flblog-$package_version.zip"
if ! wget -q "$package_url" -O "$package_file"; then
    abort "Download package file failed"
fi
subtip "Unzip package file"
package_dir="/tmp/flblog"
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
sudo chown -R nginx:nginx "$server_root"
sudo chcon -Ru system_u "$server_root"
sudo chcon -Rt httpd_sys_content_t "$server_root"

tip "Web basic authorization"
subtip "Install web tools"
sudo yum install -y httpd-tools
subtip "Create account for administrator"
sudo -u nginx touch "${config_root}/.passwd_admin"
sudo -u nginx touch "${config_root}/.passwd_manage"
sudo -u nginx htpasswd -b "${config_root}/.passwd_admin" admin "$admin_passwd"
subtip "administrator account: for admin  -> name is admin, passwd is $admin_passwd"

tip "Config nginx"
log_path=/var/log/nginx
read -d '' config <<-EOF
# for flblog
server {
   listen          80;
   listen          [::]:80;
   server_name     $server_name;
   access_log      $log_path/flblog.access.log;
   error_log       $log_path/flblog.error.log;
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
       auth_basic              "flblog admin login";
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
       auth_basic              "flblog manage login";
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
sudo tee /etc/nginx/conf.d/flblog.conf <<<"$config" >/dev/null

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
