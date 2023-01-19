---
title: "Day 10: Configure OPNsense for casting to Roku devices between VLANs"
date: 2022-06-20 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [networking, opnsense, firewall, iot]
mermaid: true
---

I have little trust in *Internet of Things (IoT)* devices. I am not even talking about smart lights, toasters, or ankle warmers; Things such as Google Chromecast, Google Home, SteamLink, and Roku devices are all IoT devices as well. IoT devices are generally less updated and less secure or they just like to poke around to see what's on your network to collect as much data about anything they can <sup>*\*cough\** *\*cough\** Google</sup>. This is why I have a separate VLAN and Wi-Fi network just for these kinds of devices. My initial configuration was that they were only allowed to talk to themselves and the internet. This would not stop them from getting compromised or run as part of a botnet, however it at least offers a layer of security between them and the rest of my home network. If I were really trying to be as secure as possible I would not run these things at all, but they are a nice convenience and I am willing to accept the risk. We all unfortunately cannot have our networks live inside of a SCIF anyway.

## Roku
I chose to start with my two Roku devices because at the time of writing they are actually the only two IoT devices I have on my network. These devices already love to ping home with tonnes of information. `scribe.logs.roku.com` is the top blocked domain on my network according to my AdGuard instance. Accounting for almost 19% of blocked requests.

![AdGuard Logs](/assets/img/posts/2022-100-days-of-homelab/day010/adguard-logs.png)

So getting these things onto the IoT network was a good idea, but I needed a way to communicate to them from my phone that is not on the IoT network. I could have easily just put my phone on the IoT network when I wanted to use the Roku. Some people even believe phones are IoT type devices as well and should just always be on there. But I have not gone down that route.

The first thing that needs to happen is there needs to be a way for the devices to find each other. To do this Roku uses SSDP, however this is normally limited to the same network that the Roku is on. This is where you need something to relay these messages between networks.

## UDP Broadcast Relay
For OPNsense there seems to be two solutions that allow mDNS and UDP broadcast realying across VLANs: `mDNS Repeater` and `UDP Broadcast Relay`<sup>[source](https://github.com/marjohn56/udpbroadcastrelay)</sup>. They are both official plugins and even though the mDNS Repeater allegedly works with Roku SSDP I was only able to get the `UDP Broadcast Relay` to work. For Roku the settings were simple enough:

![UDP Relay Settings](/assets/img/posts/2022-100-days-of-homelab/day010/udp-relay.png)

| Setting | Value |
| ----------- | ----------- |
| enabled | true |
| Relay Port | 1900 |
| Relay Interfaces | Select all interfaces you want to use, in my case IoT and Users. Minimum is two interfaces. |
| Broadcast Address | 239.255.255.250 |
| Source Address | None |
| Instance ID | 1, or any unique number between 1 and 63 |


Now once you enable and save this you probably will not see your Roku devices immediately, you still need to add a few firewall rules to allow devices to talk to each other.

## Firewall rules
### UDP Broadcast Relay
While maybe not necessary in every setup, having a firewall rule to allow connection to the UDP Broadcast Relay is probably a good idea.

![Firewall Rule for UDP Broadcast Relay](/assets/img/posts/2022-100-days-of-homelab/day010/firewall-udp-broadcast.png)

This allows for any device on that network to connect to port `1900` of `239.255.255.250` which is the IP address given in the UDP Broadcast Relay setup and it is the one that Roku connects to. Add this rule to any networks which you have allowed the UDP Broadcast Relay to work on.

### In UniFi
In UniFi in my IoT Wi-Fi network I had to enable `Multicast Enhancement` and disable `Client Device Isolation`. I'm not actually sure this last one is necessary, but I've left it off for the time being.

![UniFi Wi-Fi Settings](/assets/img/posts/2022-100-days-of-homelab/day010/unifi-settings.png)

### In OPNsense
Now while searching around the internet there seemed to be a general lack of information about what firewall rules were necessary to allow traffic between users on one VLAN to communicate with Roku on another. It appeared that most had open rule sets and were just using the broadcast relay. I ended up setting an allow all rule and then do some packet sniffing between my phone and a Roku.

![Packet Capture](/assets/img/posts/2022-100-days-of-homelab/day010/packet-capture.png)

You can see there is some initial UDP traffic from port `1900` on the Roku to establish communication, this is part of the discovery where it shows up in available devices to cast to. Then there is TCP traffic on port `8060` of the Roku once you actually connect to the device. Simple enough. We just need to create some firewall rules around this.

In your IoT network you will need to create a rule that allows any IoT device, using port 1900, to connect to any device on your other VLAN, in my case `Users`, and on any port in the range `20000-65535`. I have not noticed Roku try to use ports lower than this before and I have not had any issues using just this port range.

![IoT Firewall Rules](/assets/img/posts/2022-100-days-of-homelab/day010/firewall-iot.png)

Then in your other VLAN you will want a rule allowing any device to connect to any device on the IoT network port `8060` via TCP.

> (2022-06-22) Minor Update: After playing around for a bit I realized this did not work with casting Spotify. After a bit of packet sniffing you also need to allow port `38745` as well as the original `8060`
{: .prompt-info }

![User Firewall Rules](/assets/img/posts/2022-100-days-of-homelab/day010/firewall-users.png)

And at least for me, this was all I needed. Now I can more securely use my Roku across my Users and IoT VLAN. You could go assign your Roku a static IP and lock things down some more, but I feel this is good enough for most.

<img src="/assets/img/posts/2022-100-days-of-homelab/day010/cast.png" width="40%" />