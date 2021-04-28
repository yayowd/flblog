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

tip "Setup 19blog on macos..."

tip "Install brew, please visit https://brew.sh/"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

tip "Checking for bash version.."
if [[ ${BASH_VERSION:0:1} -lt 4 ]]; then
    subtip "Install new version of bash"
    brew install bash
    subtip "Set new bash as default"
    bash_newer=$(brew --prefix)/bin/bash
    echo $bash_newer | sudo tee -a /etc/shells >/dev/null
    chsh -s $bash_newer
    abort "Open a new terminal window and try again"
fi

tip "Install web server.."
brew install nginx fcgiwrap
subtip "Start fastcgiwrap"
fcgiwrap_root=$(brew --cellar fcgiwrap)/1.1.0
fcgiwrap_start=$fcgiwrap_root/start.sh
socket_path=/usr/local/var/run/fastcgi.sock
tee $fcgiwrap_start <<-'EOF'
rm -rf $socket_path
exec /usr/local/sbin/fcgiwrap -c 1 -f -s unix:$socket_path
EOF
chmod +x $fcgiwrap_start
tee $fcgiwrap_root/homebrew.mxcl.fcgiwrap.plist <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
   <key>Label</key>
   <string>homebrew.mxcl.fcgiwrap</string>
   <key>RunAtLoad</key>
   <true/>
   <key>KeepAlive</key>
   <true/>
   <key>ProgramArguments</key>
   <array>
       <string>$fcgiwrap_start</string>
   </array>
   <key>WorkingDirectory</key>
   <string>/usr/local</string>
   <key>StandardErrorPath</key>
   <string>/usr/local/var/log/fcgiwrap/error.log</string>
   <key>StandardOutPath</key>
   <string>/usr/local/var/log/fcgiwrap/output.log</string>
 </dict>
</plist>
EOF
brew services start fcgiwrap

tip "Make directories"
server_root=~/srv/19blog
home_root=$server_root/home
blogs_root=$server_root/blogs
cgi_root=$server_root/cgi
sudo mkdir -p ${home_root}
sudo mkdir -p ${blogs_root}
sudo mkdir -p ${cgi_root}/api
sudo mkdir -p ${cgi_root}/admin
sudo mkdir -p ${cgi_root}/manage

tip "Web basic authorization"
subtip "Create account"
touch ${cgi_root}/admin/.passwd
touch ${cgi_root}/manage/.passwd
htpasswd -b ${cgi_root}/admin/.passwd admin 123
htpasswd -b ${cgi_root}/manage/.passwd yy 123
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
tee ${home_root}/index.html <<<"$home" >/dev/null
tee ${blogs_root}/test.html <<<"$blogs" >/dev/null
tee ${cgi_root}/api/test <<<"$api" >/dev/null
tee ${cgi_root}/admin/test <<<"$admin" >/dev/null
tee ${cgi_root}/manage/test <<<"$manage" >/dev/null
chmod +x ${cgi_root}/api/test
chmod +x ${cgi_root}/admin/test
chmod +x ${cgi_root}/manage/test

tip "Config nginx"
log_path=/usr/local/var/log/nginx
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
   location /config/ {
       deny all;
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
sudo tee /usr/local/etc/nginx/servers/19blog.conf <<< "$config" >/dev/null

tip "Start nginx"
brew services start nginx

tip "Testing"
subtip "http://your.domain/             -> Welcom to 19blog"
subtip "http://your.domain/test         -> Test's blog"
subtip "http://your.domain/api/test     -> API test success"
subtip "http://your.domain/admin/test   -> Ask login: enter the administartor name and passwd set above"
subtip "                                -> Admin test success"
subtip "http://your.domain/manage/test  -> Ask login: enter the manager name and passwd set above"
subtip "                                -> Manage test success"
subtip "NOTE: When error '502 Bad Gateway' occurs, restart fcgiwrap service by:"
subtip "brew services restart fcgiwrap"
