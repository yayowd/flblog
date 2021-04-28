# 19blog
a simple blog, write in bash + vue, run at web server cgi + document root.

## FIRST
>`JUST RUN YOUR BLOG, AND WRITE AND READ.`

## INSTALL

### Script in bash
>`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yayowd/19blog/main/setup/install.sh)"`

### Manual
>more infomation in [handbook](setup/handbook.md)

## DEVELOPER GUIDE

- Install on your development machine
- Git clone the respository
- Link server root to git working diretory
  >```shell
  >$ # --archlinux/centos
  >$ sudo rm -rf /srv/19blog
  >$ sudo ln -s <git_working_diretory> /srv/19blog
  >$
  >$ # --macos
  >$ sudo rm -rf ~/srv/19blog
  >$ sudo ln -s <git_working_diretory> ~/srv/19blog
  >```
<pre>
NOTE: When you clone the respository, there has two test account
      in web basic authorization file(.passwd),
      for admin:  19blog/cgi/admin/.passwd  -> name is admin, passwd is 123
      for manage: 19blog/cgi/manage/.passwd -> name is yy,    passwd is 123
      you can also add your dev account into .passwd.
</pre>

#### DIRECTORY LIST
```
├── app          webapp source code
│   ├── home       vue home webapp
│   └── blog       vue blog webapp
├── blogs        runtime directory, save all user data
│   └── config     status and statistics
├── cgi          shell files for fastcgi
│   ├── admin      administrator pages
│   ├── api        api for webapps
│   ├── manage     manager pages
│   ├── templ      template pages
│   └── util       utility function library
└── home         distribution directory of home webapp
```

## DEMO
>[alpsibex's blog](http://blog.alpsibex.cn)
