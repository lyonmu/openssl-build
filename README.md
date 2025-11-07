# OpenSSL Docker 构建环境

这个项目提供了一个用于构建和运行 OpenSSL 的 Docker 环境，基于 Alpine Linux。

## 项目概述

本项目通过 Docker 容器提供了一个轻量级 OpenSSL 运行环境。它使用 Alpine Linux 作为基础镜像，并在此基础上编译和安装 OpenSSL

## 构建镜像

使用以下命令构建 Docker 镜像：

```bash
git submodule update --init

docker build -f Dockerfile  -t openssl:latest .
```
## 运行容器

```bash
docker run -it --rm openssl:latest openssl version -a

docker run -it --rm openssl:latest openssl list -providers

docker run -it --rm openssl:latest openssl list -all-algorithms

docker run -it --rm openssl:latest /bin/sh
```