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
    sudo pacman --needed --noconfirm -S bash
    abort "Open a new terminal window and try again"
fi

tip "Install web server.."
sudo pacman --needed --noconfirm -S nginx fcgiwrap
subtip "Start fastcgiwrap"
sudo systemctl enable fcgiwrap.socket --now
subtip "Find unix socket path of fastcgiwrap"
socket_path=$(sudo systemctl status fcgiwrap.socket | grep Listen:)
socket_path=${socket_path#*Listen: }
socket_path=${socket_path% *}

tip "Make directories"
server_root=/srv/19blog
if [ -e "$server_root" ]; then
    abort "Server root path ($server_root) exists"
fi
home_root=$server_root/home
blogs_root=$server_root/blogs
cgi_root=$server_root/cgi
sudo mkdir -p ${home_root}
sudo mkdir -p ${blogs_root}
sudo mkdir -p ${cgi_root}/api
sudo mkdir -p ${cgi_root}/admin
sudo mkdir -p ${cgi_root}/manage
sudo chown -R http:http ${server_root}

tip "Web basic authorization"
subtip "Install web tools"
sudo pacman --needed --noconfirm -S apache
subtip "Create account"
sudo -u http touch ${cgi_root}/admin/.passwd
sudo -u http touch ${cgi_root}/manage/.passwd
sudo -u http htpasswd -b ${cgi_root}/admin/.passwd admin 123
sudo -u http htpasswd -b ${cgi_root}/manage/.passwd yy 123
subtip "test account: for admin  -> name is admin, passwd is 123"
subtip "test account: for manage -> name is yy,    passwd is 123"

tip "Make demo files"
read -d '' home <<-'EOF'
<h2>Welcom to 19blog</h2>
EOF
read -d '' blogs <<-'EOF'
<h2>Test's blog</h2>
EOF
read -d '' api <<-'EOF'
#!/usr/bin/env bash
echo "HTTP/1.1 200 OK"
echo "Content-Type: text/html; charset=UTF-8"
echo
echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
echo "<h2>API test success</h2>bash version($BASH_VERSION)<br/>run as usr($(whoami))<br/><br/>$(date)"
EOF
read -d '' admin <<-'EOF'
#!/usr/bin/env bash
echo "HTTP/1.1 200 OK"
echo "Content-Type: text/html; charset=UTF-8"
echo
echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
echo "<h2>Admin test success</h2>bash version($BASH_VERSION)<br/>run as usr($(whoami))<br/><br/>$(date)"
EOF
read -d '' manage <<-'EOF'
#!/usr/bin/env bash
echo "HTTP/1.1 200 OK"
echo "Content-Type: text/html; charset=UTF-8"
echo
echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
echo "<h2>Manage test success</h2>bash version($BASH_VERSION)<br/>run as usr($(whoami))<br/><br/>$(date)"
EOF
sudo -u http tee ${home_root}/index.html <<<"$home" >/dev/null
sudo -u http tee ${blogs_root}/test.html <<<"$blogs" >/dev/null
sudo -u http tee ${cgi_root}/api/test <<<"$api" >/dev/null
sudo -u http tee ${cgi_root}/admin/test <<<"$admin" >/dev/null
sudo -u http tee ${cgi_root}/manage/test <<<"$manage" >/dev/null
sudo chmod +x ${cgi_root}/api/test
sudo chmod +x ${cgi_root}/admin/test
sudo chmod +x ${cgi_root}/manage/test

tip "Config nginx"
log_path=/var/log/nginx
server_name=domain.you
read -d '' config <<-EOF
# for 19blog
server {
   listen          80;
   listen          [::]:80;
   server_name     $server_name;
   access_log      $log_path/19blog.access.log;
   error_log       $log_path/19blog.error.log;
   location / {
       root        $home_root;
       try_files   \$uri \$uri/ @blogs;
   }
   location @blogs {
       root        $blogs_root;
       try_files   \$uri \$uri.html =404;
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
       auth_basic              "19blog login";
       auth_basic_user_file    $cgi_root/admin/.passwd;
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
       auth_basic              "19blog login";
       auth_basic_user_file    $cgi_root/manage/.passwd;
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
sudo sed -i '0,/[[:space:]]\+server {/{//i # for 19blog\ninclude 19blog.conf;\n
}' /etc/nginx/nginx.conf

tip "Start nginx"
sudo systemctl enable nginx --now

tip "Testing"
subtip "http://your.domain/             -> Welcom to 19blog"
subtip "http://your.domain/test         -> Test's blog"
subtip "http://your.domain/api/test     -> API test success"
subtip "http://your.domain/admin/test   -> Ask login: enter the administartor name and passwd set above"
subtip "                                -> Admin test success"
subtip "http://your.domain/manage/test  -> Ask login: enter the manager name and passwd set above"
subtip "                                -> Manage test success"
subtip "NOTE: When error '502 Bad Gateway' occurs, restart fcgiwrap service by:"
subtip "sudo systemctl stop fcgiwrap.service"
subtip "sudo systemctl stop fcgiwrap.socket"
subtip "sudo systemctl start fcgiwrap.socket"
