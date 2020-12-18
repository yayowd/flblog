# 19blog
a simple blog, write in bash + vue, run at web server cgi + document root.

## FIRST:
> `JUST RUN YOUR BLOG, AND WRITE AND READ.`

## Install
Most Unix-like systems have the bash shell,  
Lightweight web server (such as apache or nginx) capable of running cgi.
**NOTE** nginx need fcgiwrap to support cgi.

#### Archlinux:
> ```Shell
> $ # install
> $ sudo pacman -S nginx fcgiwrap
> $
> $ # config fcgiwrap
> $ sudo vim /usr/lib/systemd/system/fcgiwrap.service 
> $ # -  ExecStart=/usr/sbin/fcgiwrap
> $ # +  ExecStart=/usr/sbin/fcgiwrap -s unix:/tmp/fcgiwrap.sock
> $ # NOTE: DO NOT set path to /run/fcgiwrap.sock, 
> $ #       because user http cannot write to /run.
> $
> $ # update system
> $ systemctl daemon-reload
> $ systemctl enable fcgiwrap --now
> $ # NOTE: if the file /tmp/fcgiwrap.sock exist, service will start failed.
> $ #       remove the file first.
> $
> $ # find unix socket path:
> $ systemctl status fcgiwrap
> $
> $ # config nginx
> $ sudo vim /etc/nginx/nginx.conf
> $ # +  # for 19blog
> $ # +  server {
> $ # +      listen          80;
> $ # +      listen          [::]:80;
> $ # +      server_name     blog.alpsibex.cn;
> $ # +      root            /yy/srv/blog;
> $ # +      access_log      /var/log/nginx/blog.access.log;
> $ # +      error_log       /var/log/nginx/blog.error.log;
> $ # +      location / {
> $ # +          # First attemp to serve request as file, then
> $ # +          # as diretory, then fall back to displaying a 404.
> $ # +          try_files $uri $uri/ =404;
> $ # +      }
> $ # +      location ~ /cgi/ {
> $ # +          # basic authorization
> $ # +          auth_basic              "19blog admin login";
> $ # +          auth_basic_user_file    "/yy/srv/blog/cgi/htpasswd";
> $ # +          # buffer settings
> $ # +          gzip                    off;
> $ # +          client_max_body_size    0;
> $ # +          fastcgi_buffer_size     32k;
> $ # +          fastcgi_buffers         32 32k;
> $ # +          # fastcgi settings
> $ # +          include                 fastcgi.conf;
> $ # +          fastcgi_param           REMOTE_USER $remote_user;
> $ # +          fastcgi_param           PATH_INFO $1;
> $ # +          fastcgi_pass            unix:/tmp/fcgiwrap.sock;
> $ # +      }
> $ # +  }
> $ # NOTE: please set the port|domain|path|file to your own information.
> ```

## Demo:
> [alpsibex's blog](http://blog.alpsibex.cn)
