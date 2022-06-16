---
title: "Day 4: Setting up my U6-AP-Pro with VLANs and a \"cool\" Guest Portal"
date: 2022-06-14 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [networking, unifi, vlan, docker]
mermaid: true
---

Today I happened to be getting a Ubiquiti U6-AP-Pro delievered and after yesterdays stressful, but eventually successful, VLAN setup, I was destined to get VLANs on my Wi-Fi going. Thankfully, for better or for worse, the UniFi Network Application kind of abstracts a lot of the work away.

## Setup UniFi Netowrk Controller

However, first I needed to get the UniFi Network Application. To do this, I just spun up a LXC container with Docker installed. The `docker-compose.yml` file looks something like this:

```yaml
version: "3.8"
volumes:
  config:
services:
  unifi-controller:
    image: lscr.io/linuxserver/unifi-controller:latest
    container_name: unifi
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - config:/config
    ports:
      - 443:8443
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080
      - 1900:1900/udp
      - 8843:8843
      - 8880:8880
      - 6789:6789
      - 5514:5514/udp
    restart: unless-stopped
```
{: file="docker-compose.yml" }

This is basically an exact copy of the `docker-compose.yml` that Linuxserver gives, except I map port 8443 to 443 just so I don't see the dangling port in my web browser. It's also important you do not remap any of the ports as they are hard-coded into Ubiquiti devices.

If you're running this in Docker like I am, one import setting to change is in `Settings -> System` and then scroll all the way down to the bottom and look for `Overide Inform Host` (for me it was the last setting). You'll want to enable this and then give it the local IP of your Docker host

![UniFi Override Inform Host](/assets/img/posts/2022-100-days-of-homelab/day004/unifi-inform-host.png)

If you do not change this you will not be able to adopt any UniFi devices.

## VLANs