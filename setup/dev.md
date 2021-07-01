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
NOTE: When you clone the respository, there has some test account
      in web basic authorization file(.passwd),
      for admin:  19blog/cgi/admin/.passwd  -> name is admin, passwd is 123
      you can login with admin, and then add you own manager account.
      you can also change password for admin use htpasswd command.
</pre>

#### DIRECTORY LIST
```
├── app          webapp source code
│   ├── home       vue home webapp
│   └── blog       vue blog webapp
├── blogs        runtime directory, save all user data
├── cgi          shell files for fastcgi
│   ├── admin      administrator pages
│   ├── api        api for webapps
│   ├── manage     manager pages
│   ├── templ      template pages
│   └── util       utility function library
├── home         distribution directory of home webapp
└── setup        install scripts and docs
```
