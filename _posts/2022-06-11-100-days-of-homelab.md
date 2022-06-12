---
title: "#100DaysOfHomeLab: Rolling Release Day 1"
date: 2022-06-11 12:00:00 -600
categories: [homelab, 100-days]
tags: [software, docker, proxmox]
pin: true
mermaid: true
img_path: /assets/img/posts/2022-100-days-of-homelab/
---

{% assign random = site.time | date: "%s%N" %}

<script src="https://cdn.jsdelivr.net/npm/mermaid/dist/mermaid.min.js?{{ random }}"></script>

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

```mermaid
flowchart LR

    A[Proxmox] --> B1["LXC (valheim.domain.tld)"]
    A[Proxmox] --> B2["LXC (gitea.domain.tld)"]
    A[Proxmox] --> B3["LXC (...)"]
    B1 --> C1[Docker Compose]
    C1 --> D1[gitea]
    C1 --> E1[gotea_db]
    B2 --> C2[Docker Compose]
    C2 --> D2[valheim]
    B3 --> C3[Docker Compose]
    C3 --> D3[...]
    C3 --> E3[...]
```

{% for day in site.one_hundred_days reversed %}
{% if forloop.first %}
<details open markdown=block>
{% else %}
<details markdown=block>
{% endif %}
<summary style="font-size:14pt;font-weight:bold;">{{ day.title }}</summary>
{{ day.content | markdownify }}
</details>
{% endfor %}