---
title: "Day 8: Resetting it all..."
date: 2022-06-18 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [networking, opnsense, firewall]
mermaid: true
---

## The start...

I made the unfortunate mistake of making changes to my network at what appeared to me as the exact same time as Spectrum, my internet service provider, started having a complete outage in my area. This caused me to go into panic mode because I thought I had just killed my local network and at the time I did not know it was Spectrum having issues. To me it appeared my WAN was getting assigned a DHCP address from one of my VLANs so that was my cause for concern. I debugged what I thought was everything, I reset settings in my OPNsense router, factory reset my Aruba switch, factory reset my Ubiquiti access point. I even got to the point of completely reinstalling OPNsense on my router, which was a headache since I had no internet to download the OPNsense ISO.

You may be wondering, "Why didn't you just ask Spectrum if there's an outage?" Well the fun thing about Spectrum is that you need to actually log in or have your account number if you want to check that and since I have roommates, I am not the account holder and they were not available at the time to check for me.

So I spent the greater part of 3 hours debugging, checking everything twice, and then eventually resetting every piece of network hardware that I had. Fun times.

The brightside of this, if there is one, is that I was able to completely revamp my network setup. Beginning from scratch let me, or forced me to, fix some mistakes I had made in my initial setup. My VLANs are now properly set up, the OPNsense UI actually seems a bit snappier and a bug that existed in it seems to have gone away for me.

I will say that Spectrum came online about 2.5 hours after the outage began, but I may have lied a teeny tiny bit to my roommates about the internet's status while I continued to build the network back up on our side.

## WiFi pains

The wired network was easy to get up and change as I go, but my Ubiquiti access point would not show up in my UniFi Network Application, no matter how many times I factory reset it. This probably had something to do with them being on separate VLANs. I should fix but this is just a consequence of UniFi running on my Proxmox server which I have on my DMZ VLAN while the AP is on the Management VLAN. I was eventually able to ssh into the AP and point it in the right direction. I did this by using the `set-inform <host>` command and gave it the IP of my UniFi application. Once I did that it showed right up, picked up the previous settings, and the WiFi was back.

## Conclusion

While I would not classify this as a "fun" experience, I cannot say I entirely hated it either. I mean it totally was my fault going and resetting everything, but it really would have been a lot worse if I had not been learning a lot about networking and getting myself familiar with my systems on my own. It also allowed me to show myself at how far I've come. I was able to get OPNsense up and running with proper VLANs and Firewall rules in less than an hour, and resetting my switch and configuring VLANs was a piece of cake compared to just to [5 days ago]({% post_url 2022-06-13-100-Days-of-Homelab-Day-3 %}).