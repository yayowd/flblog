# 19blog
a simple blog, write in bash + vue, run at web server cgi + document root.

## FIRST:
>`JUST RUN YOUR BLOG, AND WRITE AND READ.`

## Install

#### BASH
>Most Unix-like systems have the bash shell

#### WEB SERVER
Lightweight web server (such as apache or nginx) capable of running cgi.  
NOTE: Nginx need fcgiwrap to support cgi.

- install server
>```shell
>$ sudo pacman -S nginx fcgiwrap    # archlinux
>```
- start fcgiwrap
>```shell
>$ sudo systemctl enable fcgiwrap.socket --now
>```
- find unix socket path of fcgiwrap
>```shell
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
>```
- diretories
>```shell
>$ # NOTE: The server root is which diretory your like.
>$ #       may be the /srv or /data/srv or ~/srv
>$ #       let's assume it is /srv
>$ sudo mkdir -p /srv/19blog/cgi
>$ sudo chown -R http:http /srv/19blog
>```
- web basic authorization
>```shell
>$ # install apache tools
>$ sudo pacman -S apache    # archlinux
>$ # create admin account
>$ cd /srv/19blog/cgi
>$ sudo -u http touch .passwd
>$ sudo -u http htpasswd -b .passwd <name> <passwd>
>$ # NOTE: DO NOT place passwd file in 19blog root directory,
>$ #       because 19blog root directory can be accessed directly through the web.       
>```
- make demo files
>```shell
>$ cd /srv/19blog
>$ sudo -u http tee index.html <<EOF
>Welcom to 19blog
>EOF
>
>$ cd /srv/19blog/cgi
>$ sudo -u http tee test <<'EOF'
>#!/bin/bash
>echo "HTTP/1.1 200 OK"
>echo "Content-Type: text/html; charset=UTF-8"
>echo 
>echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
>echo "<h2>cgi test success, run as usr($(whoami))</h2>"
>echo "<br/>SCRIPT_FILENAME: $SCRIPT_FILENAME"
>echo "<br/>QUERY_STRING: $QUERY_STRING"
>echo "<br/>REQUEST_METHOD: $REQUEST_METHOD"
>echo "<br/>CONTENT_TYPE: $CONTENT_TYPE"
>echo "<br/>CONTENT_LENGTH: $CONTENT_LENGTH"
>echo "<br/>SCRIPT_NAME: $SCRIPT_NAME"
>echo "<br/>REQUEST_URI: $REQUEST_URI"
>echo "<br/>DOCUMENT_URI: $DOCUMENT_URI"
>echo "<br/>DOCUMENT_ROOT: $DOCUMENT_ROOT"
>echo "<br/>SERVER_PROTOCOL: $SERVER_PROTOCOL"
>echo "<br/>REQUEST_SCHEME: $REQUEST_SCHEME"
>echo "<br/>HTTPS: $HTTPS"
>echo "<br/>GATEWAY_INTERFACE: $GATEWAY_INTERFACE"
>echo "<br/>SERVER_SOFTWARE: $SERVER_SOFTWARE"
>echo "<br/>REMOTE_ADDR: $REMOTE_ADDR"
>echo "<br/>REMOTE_PORT: $REMOTE_PORT"
>echo "<br/>SERVER_ADDR: $SERVER_ADDR"
>echo "<br/>SERVER_PORT: $SERVER_PORT"
>echo "<br/>SERVER_NAME: $SERVER_NAME"
>echo "<br/>REMOTE_USER: $REMOTE_USER"
>echo "<br/>PATH_INFO: $PATH_INFO"
>echo "<br/><br/>$(date)"
>EOF
>$ sudo chmod +x test
>$
>$ # NOTE: When the command line ends with <<EOF or <<'EOF', 
>$ #       this command contains multiple lines and is completed with a single EOF line.
>```
- config nginx
>```shell
>$ sudo vim /etc/nginx/nginx.conf
>$ # add follow lines in http module, before the exist server module
>    # for 19blog
>    server {
>        listen          80;
>        listen          [::]:80;
>        server_name     domain.you;
>        root            /srv/19blog;
>        access_log      /var/log/nginx/19blog.access.log;
>        error_log       /var/log/nginx/19blog.error.log;
>        location / {
>            # First attemp to serve request as file, then
>            # as diretory, then fall back to displaying a 404.
>            try_files $uri $uri/ =404;
>        }
>        location ~ /cgi/ {
>            # basic authorization
>            auth_basic              "19blog admin login";
>            auth_basic_user_file    /srv/19blog/cgi/.passwd;
>            # buffer settings
>            gzip                    off;
>            client_max_body_size    0;
>            fastcgi_buffer_size     32k;
>            fastcgi_buffers         32 32k;
>            # fastcgi settings
>            include                 fastcgi.conf;
>            fastcgi_param           REMOTE_USER $remote_user;
>            fastcgi_param           PATH_INFO $1;
>            fastcgi_pass            unix:/run/fcgiwrap.sock;
>        }
>    }
>$ # NOTE: In order to keep the code indentation, 
>$ #           please "set paste" for vim first, 
>$ #           and restore by "set nopaste" after pasting.
>$ #       Before start nginx service, 
>$ #           please set the port|domain|path|file to your own information.
>```
- start nginx
>```shell
>$ sudo systemctl enable nginx --now
>```
- check install
>```shell
>http://your.domain/          -> Welcom to 19blog
>http://your.domain/cgi       -> Ask login: enter the name and passwd set above
>                             -> 403 Forbidden
>http://your.domain/cgi/test  -> cgi test success
>
>NOTE: When error '502 Bad Gateway' occurs, restart fcgiwrap service by:
>$ sudo systemctl stop fcgiwrap.service
>$ sudo systemctl stop fcgiwrap.socket
>$ sudo systemctl start fcgiwrap.socket
>```
## Demo:
>[alpsibex's blog](http://blog.alpsibex.cn)
