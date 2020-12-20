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
>$ # --archlinux
>$ sudo pacman -S nginx fcgiwrap
>$
>$ # --centos
>$ sudo yum install nginx
>$ # install fcgiwrap from EPEL
>$ sudo yum install epel-release
>$ sudo yum --enablerepo=epel install fcgiwrap
>```
- start fcgiwrap
>```shell
>$ # --archlinux
>$ sudo systemctl enable fcgiwrap.socket --now
>$
>$ # --centos
>$ sudo systemctl enable fcgiwrap@nginx.socket --now
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
>$ # For the consistency of the configuration file, add a link file here
>$ sudo ln -s /run/fcgiwrap/fcgiwrap-nginx.sock /run/fcgiwrap.sock
>$
>$ # NOTE: You can find socket path in the line starting with "Listen".
>```
- diretories
>```shell
>$ # NOTE: The server root is which diretory your like.
>$ #       may be the /srv or /data/srv or ~/srv
>$ #       let's assume it is /srv
>$ sudo mkdir -p /srv/19blog/cgi
>$
>$ # --archlinux
>$ sudo chown -R http:http /srv/19blog
>$
>$ # --centos
>$ sudo chown -R nginx:nginx /srv/19blog
>$ sudo chcon -Ru system_u /srv/19blog
>$ sudo chcon -Rt httpd_sys_content_t /srv/19blog
>```
- web basic authorization
>```shell
>$ # --archlinux
>$ # install tools first
>$ sudo pacman -S apache
>$ # create admin account
>$ sudo -u http  touch /srv/19blog/cgi/.passwd
>$ sudo -u http  htpasswd -b /srv/19blog/cgi/.passwd <name> <passwd>
>$
>$ # --centos
>$ # install tools first
>$ sudo yum install httpd-tools
>$ # create admin account
>$ sudo -u nginx touch /srv/19blog/cgi/.passwd
>$ sudo -u nginx htpasswd -b /srv/19blog/cgi/.passwd <name> <passwd>
>$
>$ # NOTE: DO NOT place passwd file in 19blog root directory,
>$ #       because 19blog root directory can be accessed directly through the web.       
>```
- make demo files
>```shell
>$ read -d '' index <<-'EOF'
>	<h2>Welcom to 19blog</h2>
>	EOF
>$ read -d '' test <<-'EOF'
>	#!/bin/bash
>	echo "HTTP/1.1 200 OK"
>	echo "Content-Type: text/html; charset=UTF-8"
>	echo
>	echo "<meta http-equiv='content-type' content='text/html; charset=utf-8'>"
>	echo "<h2>cgi test success</h2>run as usr($(whoami))<br/><br/>$(date)"
>	EOF
>$
>$ # --archlinux
>$ sudo -u http tee /srv/19blog/index.html <<< "$index"
>$ sudo -u http tee /srv/19blog/cgi/test <<< "$test"
>$
>$ # --centos
>$ sudo -u nginx tee /srv/19blog/index.html <<< "$index"
>$ sudo -u nginx tee /srv/19blog/cgi/test <<< "$test"
>$
>$ sudo chmod +x /srv/19blog/cgi/test
>$
>$ # NOTE: When the command line ends with <<-'EOF', 
>$ #       which contains multiple lines and is completed with a single EOF line.
>```
- config nginx
>```shell
>$ read -d '' config <<-'EOF'
>	# for 19blog
>	server {
>	    listen          80;
>	    listen          [::]:80;
>	    server_name     domain.you;
>	    root            /srv/19blog;
>	    access_log      /var/log/nginx/19blog.access.log;
>	    error_log       /var/log/nginx/19blog.error.log;
>	    location / {
>	        # First attemp to serve request as file, then
>	        # as diretory, then fall back to displaying a 404.
>	        try_files $uri $uri/ =404;
>	    }
>	    location ~ /cgi/ {
>	        # basic authorization
>	        auth_basic              "19blog admin login";
>	        auth_basic_user_file    /srv/19blog/cgi/.passwd;
>	        # buffer settings
>	        gzip                    off;
>	        client_max_body_size    0;
>	        fastcgi_buffer_size     32k;
>	        fastcgi_buffers         32 32k;
>	        # fastcgi settings
>	        include                 fastcgi.conf;
>	        fastcgi_param           REMOTE_USER $remote_user;
>	        fastcgi_param           PATH_INFO $1;
>	        fastcgi_pass            unix:/run/fcgiwrap.sock;
>	    }
>	}
>	EOF
>$
>$ # --archlinux
>$ sudo tee /etc/nginx/19blog.conf <<< "$config"
>$ sudo vim /etc/nginx/nginx.conf
>$ # add follow line in http module, before the exist server module
>    include 19blog.conf;
>$
>$ # --centos
>$ sudo tee /etc/nginx/conf.d/19blog.conf <<< "$config"
>$
>$ # NOTE: Before start nginx service, 
>$ #       please set the port|domain|path|file to your own information.
>```
- start nginx
>```shell
>$ sudo systemctl enable nginx --now
>```
- check install
>```shell
> http://your.domain/          -> Welcom to 19blog
> http://your.domain/cgi       -> Ask login: enter the name and passwd set above
>                              -> 403 Forbidden
> http://your.domain/cgi/test  -> cgi test success
>
>$ # NOTE: If you see the welcome page of nginx, 
>$ #       please modify the domain information in the configuration file
>$ #       and access it through the domain.
>$ #
>$ # NOTE: When error '502 Bad Gateway' occurs, restart fcgiwrap service by:
>$ # --archlinux
>$ sudo systemctl stop fcgiwrap.service
>$ sudo systemctl stop fcgiwrap.socket
>$ sudo systemctl start fcgiwrap.socket
>$ # --centos
>$ sudo systemctl stop fcgiwrap@nginx.service
>$ sudo systemctl stop fcgiwrap@nginx.socket
>$ sudo systemctl start fcgiwrap@nginx.socket
>```
## Demo:
>[alpsibex's blog](http://blog.alpsibex.cn)
