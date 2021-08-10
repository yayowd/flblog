# flblog

一个简单的、在BASH环境运行的、基于单HTML文件的博客项目。

当你需要一个简约的博客，来：快速写入和阅读文字、简单干净样式、支持无脚本浏览、对个人支持多类别用户、对组织支持多角色用户、支持服务器静态缓存、支持页面保存数据备份、方便安装、迅速响应，那为什么不试试我们的flblog呢。

主要特点：
- 运行在BASH脚本环境中，无需其它运行时；
- 所有数据都在HTML中，无需数据库环境；
- 后端NGINX静态缓存，无额外资源消耗；

[English](/)

## 安装

### 脚本安装

<pre><code class="language-bash" data-lang="bash">/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yayowd/flblog/main/setup/install.sh)"</code></pre>

### 手动安装

请参阅[使用手册](setup/install.md)

## 开发者指南

### 脚本配置

<pre><code class="language-bash" data-lang="bash">/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/yayowd/flblog/main/setup/dev.sh)"</code></pre>

### 手动配置

请参阅[使用手册](setup/dev.md)

## DEMO

- [alpsibex's blog](http://blog.alpsibex.cn)
