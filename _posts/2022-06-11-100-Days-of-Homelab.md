---
title: "#100DaysOfHomeLab: Rolling Release"
date: 2022-06-11 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [software, networking]
pin: false
mermaid: true
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

<ul>
{% for post in site.categories["100-days-of-homelab"] %}
  {% if post.title != page.title %}
    <li>
      <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    </li>
  {% endif %}
{% endfor %}
</ul>