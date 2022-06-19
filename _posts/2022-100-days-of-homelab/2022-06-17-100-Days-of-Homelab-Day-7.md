---
title: "Day 7: Organizing my network on Bookstack"
date: 2022-06-17 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [bookstack, docker, networking]
mermaid: true
---

[Bookstack](https://www.bookstackapp.com/) is a self-hosted platform for storing information. I've had it running for a while, but I was pretty much empty, so I spent some time putting information into it. In my case, I use it as sort of an internal wiki to organize my homelab. The setup with docker is pretty simpe, here I am using the Linuxserver Docker image:

```yaml
version: "3"
volumes:
  config:
services:
  bookstack:
    image: lscr.io/linuxserver/bookstack
    container_name: bookstack
    environment:
      - PUID=1000
      - PGID=1000
      - APP_URL=https://wiki.domain.tld
      - DB_HOST=bookstack_db
      - DB_USER=bookstack
      - DB_PASS=
      - DB_DATABASE=bookstackapp
      - MAIL_DRIVER=smtp
      - MAIL_HOST=
      - MAIL_PORT=
      - MAIL_ENCRYPTION=tls
      - MAIL_USERNAME=
      - MAIL_PASSWORD=
      - MAIL_FROM=
      - MAIL_FROM_NAME=Bookstack
    volumes:
      - config:/config
    ports:
      - 443:443
    restart: unless-stopped
    depends_on:
      - bookstack_db
  bookstack_db:
    image: lscr.io/linuxserver/mariadb
    container_name: bookstack_db
    environment:
      - PUID=1000
      - PGID=1000
      - MYSQL_ROOT_PASSWORD=
      - TZ=America/New_York
      - MYSQL_DATABASE=bookstackapp
      - MYSQL_USER=bookstack
      - MYSQL_PASSWORD=
    volumes:
      - config:/config
    restart: unless-stopped
```
{: file="docker-compose.yml" }

I've organized all of my homelab stuff on one `Shelf` and within that I have `Books` dedicated to `Hardawre` (servers, routers, switches, access points), `Network` (vlan set up, IP tables), and `Services` (adguard, valhiem, bookstack, etc).
![Bookstack Homelab Shelf](/assets/img/posts/2022-100-days-of-homelab/day007/bookstack-homelab.png)

![Bookstack Hardware Book](/assets/img/posts/2022-100-days-of-homelab/day007/bookstack-homelab-hardware.png)

![Bookstack Network Book](/assets/img/posts/2022-100-days-of-homelab/day007/bookstack-homelab-network.png)

![Bookstack Services Book](/assets/img/posts/2022-100-days-of-homelab/day007/bookstack-homelab-services.png)