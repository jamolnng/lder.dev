---
title: "Day 6: Only allowing Cloudflare's servers onto port 443 of my network"
date: 2022-06-16 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [cloudflare, networking, opnsense, firewall]
mermaid: true
---

After a bit of a crazy week I settled on a simple task to only allow traffic from Cloudflare to access my self-hosted websites, since I use Cloudflare to proxy traffic to my websites. While Cloudflare generally does a good job at hiding your public IP address if you ask them to, if someone happens to get a hold of it they could easily access your website bypassing Cloudflare. It can be done as simply as using the `--resolve` command line argument in `cURL`:

```shell
curl -k https://example.com --resolve 'example.com:443:your_public_ip'
```
{: .nolineno }

or by creating a custom local DNS record.

While someone with your public IP still will be able to send millions of requests per minute at your router, they will be blocked there. You may still have internet issues but at least your services behind your router will not be bombarded.

## Creating an Alias for Cloudflare IP addresses

The first thing you need to do is figure out what IP addresses Cloudflare uses to connect to your server. For this I'm only going to be looking at IPv4 addresses, however their IPv6 ones are also available.

Conveniently, Cloudflare offers a nice [list of their IP address ranges](https://www.cloudflare.com/ips-v4).

Now in OPNsense, there are these things called Aliases that basically are just a list of IPs/MAC addresses/GeoIP/etc. info to identify a group of devices. We can easily create an Alias for these Cloudflare IPs.

In OPNsense under `Firewall -> Aliases` click add.

* Make sure it's enabled
* Give it a name (for instance `cloudflare`)
* Set the type to `URL Table (IPs)`
* Tell it to refresh however often you want
* For the content, give it the URL of Cloudflare IPs

Then click save.

![OPNsense Alias Cloudflare](/assets/img/posts/2022-100-days-of-homelab/day006/opnsense-alias-cloudflare.png)

## Creating Firewall Rules

Next under `Firewall -> Rules -> [WAN]` add a rule

* Action: Pass
* Interface: WAN
* Direction: in
* TCP/IP Version: IPv4
* Protocol: TCP
* Source: Select your Cloudflare alias
* Destination: This Firewall
* Destination port range: HTTPS -> HTTPS

Then click save.

![OPNsense Firewall Cloudflare](/assets/img/posts/2022-100-days-of-homelab/day006/opnsense-firewall-cloudflare.png)

That should be it, by default OPNsense blocks traffic so this will only allow Cloudflare to use TCP on the HTTPS port (443).

You can test it out by, on a computer outside your network, running the commands

```shell
curl -k https://example.com --resolve 'example.com:443:your_public_ip'
```
{: .nolineno }

and you should see something like this:

![Blocked](/assets/img/posts/2022-100-days-of-homelab/day006/blocked.png)