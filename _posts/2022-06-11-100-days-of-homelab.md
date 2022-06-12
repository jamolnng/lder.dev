---
title: "#100DaysOfHomeLab: Rolling Release Day 1"
date: 2022-06-11 12:00:00 -600
categories: [homelab, 100-days]
tags: [software, docker, proxmox]
pin: true
mermaid: true
img_path: /assets/img/posts/2022-100-days-of-homelab/
---

In one of his recent YouTube video, TechnoTim has challeneged all of us Homelabbers to the #100DaysOfHomeLab

[![100 Days of HomeLab - The HomeLab Challenge](https://img.youtube.com/vi/bwDVW_ifkBU/0.jpg)](https://www.youtube.com/watch?v=bwDVW_ifkBU "100 Days of HomeLab - The HomeLab Challenge")

The challenge is to commit at least 1 hour for the next 100 days learning or working on or about our homelabs. In this rolling post, I will update each day with what I did and/or what I am learning.

<!--
<details open>
  <summary style="font-size:14pt;font-weight:bold;">
  Day 3: Only allowing Cloudflare's servers onto port 443 of my network
  </summary>
  <div markdown="1">
  </div>
</details>
-->

<!--
<details open>
  <summary style="font-size:14pt;font-weight:bold;">
  Day 2: CI with Drone CI and Gitea
  </summary>
  <div markdown="1">
  Well the work for this post actually started in the middle of working on the post for Day 1, but ended today on Day 2. Like any good homelabber I got [nerd sniped](https://xkcd.com/356/) by myself.
  </div>
</details>
-->

<details open>
  <summary style="font-size:14pt;font-weight:bold;">
  Day 1: Deployment workflow: Valheim Server
  </summary>
  <div markdown="1">
  Recently some of my old friends and I started getting back into [Valheim](https://store.steampowered.com/app/892970/Valheim/). Last time we did this we rented out a server from one of the many server providers out there. However, as we've noticed, these servers are prone to really underperforming their listed specs. Since then I have [significantly upgraded]({{ 'about' | relative_url }}/#servers) my home lab from a lonely little Raspberry Pi 3B+.

  While setting up a Valheim server in itself is not that difficult, especially with the help of docker, until now I've really just been setting up my workflow and this is a chance for me to test it all out.

  Now the way I have things currently set up on my main server is that I run LXC containers with Docker running inside these containers for a bit of container-inception. I learned this little technique from a recent [DBTech video](https://www.youtube.com/watch?v=ksvoWpyWHUY).
  
  ```mermaid
  flowchart LR
    A[Proxmox] --> B[LXC]
    B --> C[Docker Compose]
    C --> D[app]
    C --> E[app_db]
  ```
  
  While options like [Portainer](https://www.portainer.io/) stacks exist for organization, having each "stack" on it's own LXC container makes backuping up and restoring each stack individually a whole lot easier. Instead of having to roll back everything if something goes wrong, I can just pick whichever stack I messed up. All of this at essentially an unnoticable cost to performance.

  To start, I need to spin up a new LXC container. This is pretty easy in Proxmox.

  ![Proxmox Container General Tab](day1/proxmox-create-ct-general.png)
  * We need to give it an ID, 103 in my case was available
  * A hostname: valheim.domain.tld, this can really be whatever, but giving it the domain you will access it with helps me for organization
  * Deselect "Unprivileged container" this will allow us later to let the Valheim server get more CPU cycles so it feels smoother
  * Finally give it a password

  ![Proxmox Container Template Tab](day1/proxmox-create-ct-template.png)
  * Here I'm choosing a Debian 11.3-1 template from local storage

  ![Proxmox Container Disks Tab](day1/proxmox-create-ct-disks.png)
  * Allocate some storage for it. I found that 8GB is enough but 12GB gives some head room for growth

  ![Proxmox Container Disks Tab](day1/proxmox-create-ct-cpu.png)
  * I've given my container 6 vCores on my Intel 12400, however even with a few people on it I've not managed more than 10% CPU usage

  ![Proxmox Container Memory Tab](day1/proxmox-create-ct-memory.png)
  * 8GB RAM is more than enough, at idle it only uses 2.5GB and it barely goes up as people join

  ![Proxmox Container Network Tab](day1/proxmox-create-ct-network.png)
  * I've selected to use DHCP to get the IP address for this container, I like to set the static routes in my DHCP server (in my case my OPNsense router) to stay organized

  ![Proxmox Container DNS Tab](day1/proxmox-create-ct-dns.png)
  * I ignore the DNS tab because I let my DHCP server provide the DNS details the the container

  ![Proxmox Container DNS Tab](day1/proxmox-create-ct-confirm.png)
  * Finally, set it to start after creating and click confirm
  </div>
</details>