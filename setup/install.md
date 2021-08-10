## INSTALL

#### Bash
Most Unix-like systems have the bash shell
>```shell
>$ # --archlinux/centos are generally installed bash
>$ #   make sure the bash version is 4.0+
>$
>$ # --macos also installed bash, but the version is older
>$ #   macos 10.15.7+:
>$ #     /bin/bash --version 
>$ #       > GNU bash, version 3.2.57(1)-release
>$ #   please use brew to install the new version of bash
>$ # install brew, please visit https://brew.sh/
>$ #   if you are in China, please set up domestic source after installation.
>$ #     please visit https://developer.aliyun.com/mirror/homebrew
>$ /bin/bash -c "(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
>$ # install new version of bash
>$ brew install bash
>$ #
>$ # REMIND: if you want set new bash as default
>$ bash_newer=$(brew --prefix)/bin/bash
>$ echo $bash_newer | sudo tee -a /etc/shells
>$ chsh -s $bash_newer
>$ # open a new terminal window, check bash version
>$ echo $BASH_VERSION
>$ # > 5.0.18(1)-release
>$ #
>$ # REMIND: if you want use new bash in idea terminal
>$ #   Preferences... > Tools > Terminal > Application Settings > Shell path
>$ #     /bin/bash -c "/usr/local/bin/bash -l -i"
>$ # NOTE: the error will occurs if you set to /usr/local/bin/bash
>$ #         shell-init: error retrieving current directory: getcwd: cannot access parent directories: Undefined error: 0
>$ #         and the current work diretory is not you project root dicretory
>```

#### Web Server
Lightweight web server (such as apache or nginx) capable of running cgi.  
NOTE: Nginx need fcgiwrap to support cgi.

- install server
>```shell
>$ # --archlinux
>$ sudo pacman -S nginx fcgiwrap
>$
>$ # --centos
>$ sudo yum install nginx
>$ # install fcgiwrap from EPEL
>$ sudo yum install epel-release
>$ sudo yum --enablerepo=epel install fcgiwrap
>$
>$ # --macos
>$ brew install nginx fcgiwrap
>```
- start fcgiwrap
>```shell
>$ # --archlinux
>$ sudo systemctl enable fcgiwrap.socket --now
>$
>$ # --centos
>$ sudo systemctl enable fcgiwrap@nginx.socket --now
>$
>$ # --macos
>$ # check fcgiwrap version
>$ fcgiwrap -h
>$ # create auxiliary files, NOTE the fcgiwrap version is 1.1.0 here
>$ fcgiwrap_root=$(brew --cellar fcgiwrap)/1.1.0
>$ fcgiwrap_start=$fcgiwrap_root/start.sh
>$ tee $fcgiwrap_start <<-'EOF'
>rm -rf /usr/local/var/run/fastcgi.sock
>exec /usr/local/sbin/fcgiwrap -c 1 -f -s unix:/usr/local/var/run/fastcgi.sock
>EOF
>$ chmod +x $fcgiwrap_start
>$ tee $fcgiwrap_root/homebrew.mxcl.fcgiwrap.plist <<-EOF
><?xml version="1.0" encoding="UTF-8"?>
><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
><plist version="1.0">
><dict>
>    <key>Label</key>
>    <string>homebrew.mxcl.fcgiwrap</string>
>    <key>RunAtLoad</key>
>    <true/>
>    <key>KeepAlive</key>
>    <true/>
>    <key>ProgramArguments</key>
>    <array>
>        <string>$fcgiwrap_start</string>
>    </array>
>    <key>WorkingDirectory</key>
>    <string>/usr/local</string>
>    <key>StandardErrorPath</key>
>    <string>/usr/local/var/log/fcgiwrap/error.log</string>
>    <key>StandardOutPath</key>
>    <string>/usr/local/var/log/fcgiwrap/output.log</string>
>  </dict>
></plist>
>EOF
>$ # start fcgiwrap service
>$ brew services start fcgiwrap
>$
>$ # NOTE: When the command line ends with <<-EOF or <<-'EOF', 
>$ #       which contains multiple lines and is completed with a single EOF line.
>```
- find unix socket path of fcgiwrap
>```shell
>$ # --archlinux
>$ sudo systemctl status fcgiwrap.socket
>$ # > ● fcgiwrap.socket - fcgiwrap Socket
>$ # >      Loaded: loaded (/usr/lib/systemd/system/fcgiwrap.socket; enabled; vendor preset: disabled)
>$ # >      Active: active (running) since Fri 2020-12-18 19:18:19 CST; 9min ago
>$ # >    Triggers: ● fcgiwrap.service
>$ # >      Listen: /run/fcgiwrap.sock (Stream)
>$ # >       Tasks: 0 (limit: 1141)
>$ # >      Memory: 0B
>$ # >      CGroup: /system.slice/fcgiwrap.socket
>$ # NOTE: You can find socket path in the line starting with "Listen".
>$
>$ # --centos
>$ sudo systemctl status fcgiwrap@nginx.socket
>$ # > ● fcgiwrap@nginx.socket - fcgiwrap Socket
>$ # >    Loaded: loaded (/usr/lib/systemd/system/fcgiwrap@.socket; enabled; vendor preset: disabled)
>$ # >    Active: active (listening) since Sun 2020-12-20 10:25:31 CST; 1min 14s ago
>$ # >    Listen: /run/fcgiwrap/fcgiwrap-nginx.sock (Stream)
>$ # >     Tasks: 0 (limit: 4696)
>$ # >    Memory: 68.0K
>$ # >    CGroup: /system.slice/system-fcgiwrap.slice/fcgiwrap@nginx.socket
>$ # NOTE: You can find socket path in the line starting with "Listen".
>$
>$ # --macos
>$ # the unix socket path is writen in start file
>$ #   > /usr/local/var/run/fastcgi.sock
>```
- directories
>```shell
>$ # NOTE: The server root is which directory your like.
>$ #       may be the /srv or ~/srv or /data/srv
>$ #       let's assume it is /srv(archlinux/centos) or ~/srv(macos)
>$
>$ # --archlinux
>$ sudo mkdir -p /srv/flblog/home
>$ sudo mkdir -p /srv/flblog/blogs
>$ sudo mkdir -p /srv/flblog/cgi/api
>$ sudo mkdir -p /srv/flblog/cgi/admin
>$ sudo mkdir -p /srv/flblog/cgi/manage
>$ sudo chown -R http:http /srv/flblog
>$
>$ # --centos
>$ sudo mkdir -p /srv/flblog/home
>$ sudo mkdir -p /srv/flblog/blogs
>$ sudo mkdir -p /srv/flblog/cgi/api
>$ sudo mkdir -p /srv/flblog/cgi/admin
>$ sudo mkdir -p /srv/flblog/cgi/manage
>$ sudo chown -R nginx:nginx /srv/flblog
>$ sudo chcon -Ru system_u /srv/flblog
>$ sudo chcon -Rt httpd_sys_content_t /srv/flblog
>$ # NOTE: In centos 8.2, chcon with error:
>$ #       "chcon: can't apply partial context to unlabeled file 'xxx'"
>$ #       please ignore it.
>$
>$ # --macos
>$ mkdir -p ~/srv/flblog/home
>$ mkdir -p ~/srv/flblog/blogs
>$ mkdir -p ~/srv/flblog/cgi/api
>$ mkdir -p ~/srv/flblog/cgi/admin
>$ mkdir -p ~/srv/flblog/cgi/manage
>```
- web basic authorization
>```shell
>$ # --archlinux
>$ # install tools first
>$ sudo pacman -S apache
>$ # create account
>$ sudo -u http  touch /srv/flblog/cgi/admin/.passwd
>$ sudo -u http  touch /srv/flblog/cgi/manage/.passwd
>$ sudo -u http  htpasswd -b /srv/flblog/cgi/admin/.passwd <name> <passwd>
>$ sudo -u http  htpasswd -b /srv/flblog/cgi/manage/.passwd <name> <passwd>
>$
>$ # --centos
>$ # install tools first
>$ sudo yum install httpd-tools
>$ # create account
>$ sudo -u nginx touch /srv/flblog/cgi/admin/.passwd
>$ sudo -u nginx touch /srv/flblog/cgi/manage/.passwd
>$ sudo -u nginx htpasswd -b /srv/flblog/cgi/admin/.passwd <name> <passwd>
>$ sudo -u nginx htpasswd -b /srv/flblog/cgi/manage/.passwd <name> <passwd>
>$
>$ # --macos
>$ # create account
>$ touch ~/srv/flblog/cgi/admin/.passwd
>$ touch ~/srv/flblog/cgi/manage/.passwd
>$ htpasswd -b ~/srv/flblog/cgi/admin/.passwd <name> <passwd>
>$ htpasswd -b ~/srv/flblog/cgi/manage/.passwd <name> <passwd>
>$
>$ # NOTE: ONLY admin and manage cgi need authorized.
>```
- make demo files
>```shell
>$ read -d '' home <<-'EOF'
><h2>Welcom to flblog</h2>
>EOF
>$ read -d '' blogs <<-'EOF'
><h2>Test's blog</h2>
>EOF
>$ read -d '' api <<-'EOF'
>#!/usr/bin/env bash
>echo "HTTP/1.1 200 OK"
>echo "Content-Type: text/html; charset=UTF-8"
>echo
>echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
>echo "<h2>API test success</h2>bash version($BASH_VERSION)<br/>run as usr($(whoami))<br/><br/>$(date)"
>EOF
>$ read -d '' admin <<-'EOF'
>#!/usr/bin/env bash
>echo "HTTP/1.1 200 OK"
>echo "Content-Type: text/html; charset=UTF-8"
>echo
>echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
>echo "<h2>Admin test success</h2>bash version($BASH_VERSION)<br/>run as usr($(whoami))<br/><br/>$(date)"
>EOF
>$ read -d '' manage <<-'EOF'
>#!/usr/bin/env bash
>echo "HTTP/1.1 200 OK"
>echo "Content-Type: text/html; charset=UTF-8"
>echo
>echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
>echo "<h2>Manage test success</h2>bash version($BASH_VERSION)<br/>run as usr($(whoami))<br/><br/>$(date)"
>EOF
>$
>$ # --archlinux
>$ sudo -u http tee /srv/flblog/home/index.html <<< "$home"
>$ sudo -u http tee /srv/flblog/blogs/test.html <<< "$blogs"
>$ sudo -u http tee /srv/flblog/cgi/api/test <<< "$api"
>$ sudo -u http tee /srv/flblog/cgi/admin/test <<< "$admin"
>$ sudo -u http tee /srv/flblog/cgi/manage/test <<< "$manage"
>$ sudo chmod +x /srv/flblog/cgi/api/test
>$ sudo chmod +x /srv/flblog/cgi/admin/test
>$ sudo chmod +x /srv/flblog/cgi/manage/test
>$
>$ # --centos
>$ sudo -u nginx tee /srv/flblog/home/index.html <<< "$home"
>$ sudo -u nginx tee /srv/flblog/blogs/test.html <<< "$blogs"
>$ sudo -u nginx tee /srv/flblog/cgi/api/test <<< "$api"
>$ sudo -u nginx tee /srv/flblog/cgi/admin/test <<< "$admin"
>$ sudo -u nginx tee /srv/flblog/cgi/manage/test <<< "$manage"
>$ sudo chmod +x /srv/flblog/cgi/api/test
>$ sudo chmod +x /srv/flblog/cgi/admin/test
>$ sudo chmod +x /srv/flblog/cgi/manage/test
>$
>$ # --macos
>$ tee ~/srv/flblog/home/index.html <<< "$home"
>$ tee ~/srv/flblog/blogs/test.html <<< "$blogs"
>$ tee ~/srv/flblog/cgi/api/test <<< "$api"
>$ tee ~/srv/flblog/cgi/admin/test <<< "$admin"
>$ tee ~/srv/flblog/cgi/manage/test <<< "$manage"
>$ chmod +x ~/srv/flblog/cgi/api/test
>$ chmod +x ~/srv/flblog/cgi/admin/test
>$ chmod +x ~/srv/flblog/cgi/manage/test
>```
- config nginx
>```shell
>$ # --archlinux
>$ log_path=/var/log/nginx
>$ server_root=/srv/flblog
>$ socket_path=/run/fcgiwrap.sock
>$
>$ # --centos
>$ log_path=/var/log/nginx
>$ server_root=/srv/flblog
>$ socket_path=/run/fcgiwrap/fcgiwrap-nginx.sock
>$
>$ # --macos
>$ log_path=/usr/local/var/log/nginx
>$ server_root=$(cd ~; pwd)/srv/flblog
>$ socket_path=/usr/local/var/run/fastcgi.sock
>$
>$ home_root=$server_root/home
>$ blogs_root=$server_root/blogs
>$ cgi_root=$server_root/cgi
>$ server_name=domain.you
>$
>$ read -d '' config <<-EOF
># for flblog
>server {
>    listen          80;
>    listen          [::]:80;
>    server_name     $server_name;
>    access_log      $log_path/flblog.access.log;
>    error_log       $log_path/flblog.error.log;
>    location / {
>        root        $home_root;
>        try_files   \$uri \$uri/ @blogs;
>    }
>    location @blogs {
>        root        $blogs_root;
>        try_files   \$uri \$uri.html =404;
>    }
>    location ~ /api/ {
>        root                    $cgi_root;
>        # buffer settings
>        gzip                    off;
>        client_max_body_size    0;
>        fastcgi_buffer_size     32k;
>        fastcgi_buffers         32 32k;
>        # fastcgi settings
>        include                 fastcgi.conf;
>        fastcgi_param           REMOTE_USER \$remote_user;
>        fastcgi_param           PATH_INFO \$1;
>        fastcgi_pass            unix:$socket_path;
>    }
>    rewrite ^/admin$ /admin/index permanent;
>    location ~ /admin/ {
>        root                    $cgi_root;
>        # basic authorization
>        auth_basic              "flblog login";
>        auth_basic_user_file    $cgi_root/admin/.passwd;
>        # buffer settings
>        gzip                    off;
>        client_max_body_size    0;
>        fastcgi_buffer_size     32k;
>        fastcgi_buffers         32 32k;
>        # fastcgi settings
>        include                 fastcgi.conf;
>        fastcgi_param           REMOTE_USER \$remote_user;
>        fastcgi_param           PATH_INFO \$1;
>        fastcgi_pass            unix:$socket_path;
>    }
>    rewrite ^/manage$ /manage/index permanent;
>    location ~ /manage/ {
>        root                    $cgi_root;
>        # basic authorization
>        auth_basic              "flblog login";
>        auth_basic_user_file    $cgi_root/manage/.passwd;
>        # buffer settings
>        gzip                    off;
>        client_max_body_size    0;
>        fastcgi_buffer_size     32k;
>        fastcgi_buffers         32 32k;
>        # fastcgi settings
>        include                 fastcgi.conf;
>        fastcgi_param           REMOTE_USER \$remote_user;
>        fastcgi_param           PATH_INFO \$1;
>        fastcgi_pass            unix:$socket_path;
>    }
>}
>EOF
>$
>$ # --archlinux
>$ sudo tee /etc/nginx/flblog.conf <<< "$config"
>$ sudo vim /etc/nginx/nginx.conf
>$ # add follow line in http module, before the exist server module
>    include flblog.conf;
>$
>$ # --centos
>$ sudo tee /etc/nginx/conf.d/flblog.conf <<< "$config"
>$
>$ # --macos
>$ sudo tee /usr/local/etc/nginx/servers/flblog.conf <<< "$config"
>$
>$ # NOTE: Before start nginx service, 
>$ #       please set the port|domain|path|file to your own information.
>```
- start nginx
>```shell
>$ # --archlinux/centos
>$ sudo systemctl enable nginx --now
>$
>$ # --macos
>$ brew services start nginx
>```
- check install
>```shell
> http://your.domain/               -> Welcom to flblog
> http://your.domain/test           -> Test's blog
> http://your.domain/api/test       -> API test success
> http://your.domain/admin/test     -> Ask login: enter the administartor name and passwd set above
>                                   -> Admin test success
> http://your.domain/manage/test    -> Ask login: enter the manager name and passwd set above
>                                   -> Manage test success
>
>$ # NOTE: If you see the welcome page of nginx, 
>$ #       please modify the domain information in the configuration file
>$ #       and access it through the domain.
>$
>$ # NOTE: When error '502 Bad Gateway' occurs, restart fcgiwrap service by:
>$ # --archlinux
>$ sudo systemctl stop fcgiwrap.service
>$ sudo systemctl stop fcgiwrap.socket
>$ sudo systemctl start fcgiwrap.socket
>$ # --centos
>$ sudo systemctl stop fcgiwrap@nginx.service
>$ sudo systemctl stop fcgiwrap@nginx.socket
>$ sudo systemctl start fcgiwrap@nginx.socket
>$ # --macos
>$ brew services restart fcgiwrap
>```
