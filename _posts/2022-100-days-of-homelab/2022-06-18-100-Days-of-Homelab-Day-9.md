---
title: "Day 9: Moving from HAProxy to Traefik"
date: 2022-06-19 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [docker, proxy, traefik, haproxy, dns]
mermaid: true
---

I run my fair share of self-hosted applications and 18 of those have Web UIs. Forwarding ports for the public ones and remembering those ports as well as domain names could get confusing and is not best practice. This is where a reverse proxy comes in handy. A reverse proxy accepts all your incoming traffic and forward it to the correct backend based on the hostname or port.

## Security concerns
In my quick and dirty initial set up I had those running off of HAProxy on my OPNsense router since there is official plugin support for it. However, since I have been beefing up my security and locking things down on my network a bit, I figured it was best to not have my public facing proxy running on my router. Even though everything is already [proxied through Cloudflare]({% post_url 2022-06-16-100-Days-of-Homelab-Day-6 %}) and my firewall blocks the rest, I still felt moving it off the router onto its own service in my DMZ network add another layer.

## Traefik
[Traefik](https://traefik.io/) is a edge-router and reverse proxy that [I have used before]({% post_url 2022-06-15-100-Days-of-Homelab-Day-5 %}). While I will not be using some of the best features, like the auto-discovery of docker containers (since Traefik will be running on its own host), it is still a great application to use and is has good documentation.

To get started with Traefik you will need for files:
* Your `docker-compose.yml`
* A Traefik config `traefik.yml`
* A server config `config.yml`
* And an empty `acme.json`

Starting with the `docker-compose.yml`, this creates the Traefik host and registers itself under the domain `traefik.example.com`

```yaml
version: '3'

services:
  traefik:
    image: traefik:latest
    container_name: traefik
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    networks:
      - proxy
    ports:
      - 80:80
      - 443:443
    environment:
      - CF_API_EMAIL=email@example.com
      - CF_DNS_API_TOKEN=
      # - CF_API_KEY=YOU_API_KEY
      # be sure to use the correct one depending on if you are using a token or key
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - /home/username/docker/traefik/data/traefik.yml:/traefik.yml:ro

      # touch /home/username/traefik/data/acme.json && chmod 600 /home/username/traefik/data/acme.json
      - /home/username/docker/traefik/data/acme.json:/acme.json
      - /home/username/docker/traefik/data/config.yml:/config.yml:ro
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.traefik.entrypoints=http"
      - "traefik.http.routers.traefik.rule=Host(`traefik.example.com`)"

      # apt install apache2-utils
      # echo $(htpasswd -nb "<USER>" "<PASSWORD>") | sed -e s/\\$/\\$\\$/g
      - "traefik.http.middlewares.traefik-auth.basicauth.users=USER:HASHED_PASSWORD"
      - "traefik.http.middlewares.traefik-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https"
      - "traefik.http.routers.traefik.middlewares=traefik-https-redirect"
      - "traefik.http.routers.traefik-secure.entrypoints=https"
      - "traefik.http.routers.traefik-secure.rule=Host(`traefik.example.com`)"
      - "traefik.http.routers.traefik-secure.middlewares=traefik-auth"
      - "traefik.http.routers.traefik-secure.tls=true"
      - "traefik.http.routers.traefik-secure.tls.certresolver=cloudflare"
      - "traefik.http.routers.traefik-secure.tls.domains[0].main=example.com"
      - "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.example.com"
      - "traefik.http.routers.traefik-secure.service=api@internal"

networks:
  proxy:
    external: true
```
{: file="docker-compose.yml" }

Next the `traefik.yml`. This configures Traefik itself. Here we tell it to have two entry points, on ports 80 and 443, but to redirect all the traffic on 80 to 443 using HTTPS. Then it tells Traefik that there are two providers: Docker and a file based one. These providers configure Traefik to talk to your backends. Also, while I am not using any Docker auto-discovery features, it is important to keep the docker provider because Traefik uses this to run the ACME client to generate your TLS certificates.

```yaml
api:
  dashboard: true
  debug: false
entryPoints:
  http:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: https
          scheme: https
          permanent: true
  https:
    address: ":443"
serversTransport:
  insecureSkipVerify: true
providers:
  docker:
    endpoint: "unix:///var/run/docker.sock"
    exposedByDefault: false
  file:
    filename: /config.yml
certificatesResolvers:
  cloudflare:
    acme:
      email: mail@example.com
      storage: acme.json
      dnsChallenge:
        provider: cloudflare
        resolvers:
          - "1.1.1.1:53"
          - "1.0.0.1:53"
```
{: file="traefik.yml" }

Then you'll need a `config.yml`. This, as previously mentioned, is one way to configure your backend servers for Traefik. Here I've configured two example servers. The first `example` will be accessible through Traefik at the domain `example.domain.tld` and the second `secure_example` will be accessible similarly through the domain `secure_example.domain.tld`. What makes these two different is that `secure_example` is using the `secure` middleware created at the bottom of the file. This middleware limits access to `secure_example.domain.tld` to only IP addresses coming from a local network. This means if someone tried to get to `secure_example.domain.tld` outside of your network Traefik would block the request.

```yaml
http:
  routers:
    example:
      entryPoints:
        - "https"
      rule: "Host(`example.domain.tld`)"
      middlewares:
        - default-headers
        - https-redirect
      tls: {}
      service: example
    secure_example:
      entryPoints:
        - "https"
      rule: "Host(`secure_example.domain.tld`)"
      middlewares:
        - secured
        - https-redirect
      tls: {}
      service: secure_example

  services:
    example:
      loadBalancer:
        servers:
          - url: "https://10.0.0.1"
        passHostHeader: true
    secure_example:
      loadBalancer:
        servers:
          - url: "https://10.0.0.2"
        passHostHeader: true

  middlewares:
    https-redirect:
      redirectScheme:
        scheme: https
        permanent: true

    default-headers:
      headers:
        frameDeny: true
        sslRedirect: true
        browserXssFilter: true
        contentTypeNosniff: true
        forceSTSHeader: true
        stsIncludeSubdomains: true
        stsPreload: true
        stsSeconds: 15552000
        customFrameOptionsValue: SAMEORIGIN
        customRequestHeaders:
          X-Forwarded-Proto: https

    default-whitelist:
      ipWhiteList:
        sourceRange:
        - "10.0.0.0/8"
        - "192.168.0.0/16"
        - "172.16.0.0/12"

    secured:
      chain:
        middlewares:
        - default-whitelist
        - default-headers

```
{: file="config.yml" }

Finally, you'll need a `acme.json` file. This file is going to be empty and Traefik will fill it with your TLS certificates when it starts up. However, you need to make sure this file has the correct permissions so after you create it, using `touch acme.json` for example, you need to change its permissions by doing `chmod 600 acme.json`.

With these files in the correct place, in this example:
```
./traefik
├── data
│   ├── acme.json
│   ├── config.yml
│   └── traefik.yml
└── docker-compose.yml
```

You can simply run `docker compose up -d` and Traefik will start, register your backends given in your `config.yml` file, and start doing the DNS-01 challenges to generate your TLS certificates. Please note that it may take a few minutes for your certificates to be generated. Your sites will be accessible during this time, but you may see warnings in your browser.

Now just make sure you have the correct DNS records to point you to your websites and you should be good to go accessing them. Speaking of DNS...

## DNS-01 challenge problems
> *It's always DNS* - Jeff Geerling

I run [AdGuard Home](https://adguard.com/en/adguard-home/overview.html) on my network and through a series of firewall rules and internal port forwarding, I redirect all DNS traffic (except DNS-over-HTTPS) to AdGuard. The problem with AdGuard is that it simply is not a full DNS Server but a DNS Rewriter, so it needs a DNS Server backend, in my case [Unbound](https://github.com/NLnetLabs/unbound). This became an issue for me when Traefik tried to automatically generate TLS certificates using Let's Encrypt. The problem I had is that I gave AdGuard a simple wildcard domain rewrite to redirect all traffic at `*.mydomain.tld` to Traefik. The issue is that AdGuard has no idea about the different types of DNS records so it will just overwrite them based on domain, or at least it appears that way. When Traefik does a DNS-01 challenge on your domain to generate certificates it will create and then request a TXT record along the lines of `acme_challenge.domain.tld = SomeRandomString`. Once it verifies that record has been created it deletes it and generates your certificates. But if you have a wildcard domain rewrite in AdGuard it will rewrite the TXT record and Traefik never validates your DNS record. I spent way too long messing with firewall rules and eventually letting just my Traefik server use another DNS besides my own before I figured this out.

TLDR: don't use wildcard rewrites in AdGuard.