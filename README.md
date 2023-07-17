<p align="center">
  <img src="https://raw.githubusercontent.com/mayswind/AriaNg-Native/master/assets/AriaNg.ico" />
</p>

# [Aria2](https://github.com/aria2/aria2) + [AriaNg webui](https://github.com/mayswind/AriaNg) inside a [docker container](https://hub.docker.com/r/ganeshkakade/aria2-ariang)

- **[GitHub](https://github.com/ganeshkakade/aria2-ariang)**
- **[Docker Hub](https://hub.docker.com/r/ganeshkakade/aria2-ariang)**

## Introduction

AriaNg is a modern web frontend making [Aria2](https://github.com/aria2/aria2) easier to use. AriaNg is written in pure html & javascript, thus it does not need any compilers or runtime environment. You can just put AriaNg in your web server and open it in your browser. AriaNg uses responsive layout, and supports any desktop or mobile devices.

## Table of Contents

- [Screenshots](#screenshots)
- [Demo website](#demo-website)
- [Usage](#usage)
  - [Docker](#docker)
  - [docker-compose](#docker-compose)
  - [Nginx](#running-behind-nginx-proxy)
  - [Supported environment variables](#supported-environment-variables)
  - [Supported volumes](#supported-volumes)
  - [User / Group identifiers](#user-/-group-identifiers)
- [Building](#building)

## Screenshots

### Desktop

![AriaNg](https://raw.githubusercontent.com/mayswind/AriaNg-WebSite/master/screenshots/desktop.png)

### Mobile device

![AriaNg](https://raw.githubusercontent.com/mayswind/AriaNg-WebSite/master/screenshots/mobile.png)

## Demo website

Please visit [http://ariang.mayswind.net/latest](http://ariang.mayswind.net/latest)

## Usage

### Docker

```bash
docker run -d --name aria2-ariang -p 6800:6800 -p 8080:8080 ganeshkakade/aria2-ariang
```

To run as a different user and to map custom volume locations use:

```bash
docker run -d \
    --name aria2-ariang \
    -p 6800:6800 \
    -p 8080:8080 \
    -v /config:/aria2/config \
    -v /downloads:/aria2/downloads \
    -e PUID=1000 \
    -e PGID=1000 \
    -e RPC_SECRET=<RPC_SECRET> \
    ganeshkakade/aria2-ariang
```

### docker-compose

Minimal `docker-compose.yml` may look like this:

```yaml
version: '3'

services:
  aria2-ariang:
    container_name: aria2-ariang
    image: ganeshkakade/aria2-ariang
    ports:
      - 6800:6800
      - 8080:8080
    volumes:
      - /config:/aria2/config
      - /downloads:/aria2/downloads
    environment:
      - PUID=1000
      - PGID=1000
      - RPC_SECRET=<RPC_SECRET>
    restart: unless-stopped
```

Simply run:

```bash
docker-compose up -d
```

### Running behind Nginx proxy

You can use this nginx config:

```nginx
location / {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_set_header X-Real-IP $remote_addr;
    # proxy_set_header X-Forwarded-Proto https;
    proxy_pass http://127.0.0.1:5002;

    # enables WS support
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";

    proxy_read_timeout 999999999;
}
```

### Supported environment variables

- `PUID` - UserId who will own all downloaded files and configuration files (Default `0` which is root)
- `PGID` - GroupId who will own all downloaded files and configuration files (Default `0` which is root)
- `RPC_SECRET` - The Aria2 RPC secret token (Default: not set)
- `BASIC_AUTH_USERNAME` - username for basic auth
- `BASIC_AUTH_PASSWORD` - password for basic auth

> Note, both `BASIC_AUTH_USERNAME` and `BASIC_AUTH_PASSWORD` must be set in order to enable basic authentication.

### Supported volumes

- `/aria2/config` The Aria2 configuration file
- `/aria2/downloads` The folder of all Aria2 downloaded files

### User / Group identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1001` and `PGID=1001`, to find yours use `id user` as below:

```bash
id username
    uid=1001(dockeruser) gid=1001(dockergroup) groups=1001(dockergroup)
```

## Building

```bash
git clone https://github.com/ganeshkakade/aria2-ariang
cd aria2-ariang
docker build -t ganeshkakade/aria2-ariang .
```
