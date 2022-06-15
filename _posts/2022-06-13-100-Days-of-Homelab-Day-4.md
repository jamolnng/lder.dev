---
title: "Day 4: Setting up my U6-AP-Pro with VLANs and a "cool" Guest Portal"
date: 2022-06-14 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [networking, unifi, vlan]
mermaid: true
---

<div class="mermaid">
    graph TD 
    A[Client] -->|tcp_123| B
    B(Load Balancer) 
    B -->|tcp_456| C[Server1] 
    B -->|tcp_456| D[Server2]
</div>