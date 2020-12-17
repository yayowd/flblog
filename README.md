# 19blog
a simple blog, write in bash + vue, run at web server cgi + document root.

## Install
Most Unix-like systems have the bash shell,
Lightweight web server (such as apache or nginx) capable of running cgi.
Note that nginx need fcgiwrap to support cgi.

Archlinux:
1. install nginx and fcgiwrap
   
   >`sudo pacman -S nginx`  
   `sudo pacman -S fcgiwrap`
2. config fcgiwrap  
   `sudo vim /usr/lib/systemd/system/fcgiwrap.service`
   
   >`- ExecStart=/usr/sbin/fcgiwrap`  
   >`+ ExecStart=/usr/sbin/fcgiwrap -s unix:/tmp/fcgiwrap.sock`
   
   **note: do not set path to /run/fcgiwrap.sock, because user http cannot write to /run**  
   update system config:  
   >`systemctl daemon-reload`
   
