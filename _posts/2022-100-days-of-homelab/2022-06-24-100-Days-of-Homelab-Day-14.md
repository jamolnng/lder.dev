---
title: "Day 14: Installing &ldquo;new&rdquo; HDDs in unRAID and Proxmox"
date: 2022-06-24 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [hardware]
---

## unRAID

I was not running out of room on my unRAID server by any means. However as a homelabber it is always tempting to upgrade when the opportunity strikes. This opportunity happened to be a [Amazon Warehouse](https://smile.amazon.com/Warehouse-Deals/b?ie=UTF8&node=10158976011) sale of 2x4TB Seagate Compute drives. They were $30 total for the both of them. Pretty good deal.

The only issue is that you never really know what you are going to get buying used items off Amazon. Sometimes you will get brand new, sometimes you will get drives with thirty-thousand hours on them.

Lucky for me I got brand new drives, sealed in their original packaging and anti-static bags. The S.M.A.R.T. data for each showed two minutes of power on time after I plugged them in and checked within unRAID.

Now this does not mean I should trust the drives to work perfectly. You never know how they were handled by the person that returned them or during shipping. This applies to drives you bought new as well.

To make sure the drives are ready to be added to the array, you should burn in the drives. In unRAID there is a plugin called "Unassigned Devices Preclear" that will let you burn in the drives. It does this by reading the entire drive, then writing zeros to every bit, then reading the entire drive again. This ensures that the entire drive is working and it will give you warnings or errors if there are issues.

Both of my new drives passed the burn in test so I was ready to add them to the array. I did this by first adding the data drive and starting the array, then I stopped the array and added my second parity drive. Once I started the array again the parity build began for the second parity drive and the array was ready to be used.

Now I have 20TB of raw storage, 12TB data and 8TB parity. This may seem like a high parity to data ratio but I call it peace of mind.

Here you can see the array now while it builds the parity on the new drive:

![unRAID Array of Drives](/assets/img/posts/2022-100-days-of-homelab/day014/array.png)

## Proxmox

I had a 2TB WD Black drive hanging around that I kept forgetting about so I installed it on my Proxmox server. I then moved my NFS shares that were shared from unRAID for keeping my Docker data to this 2TB drive. I then set Proxmox up to backup data from the 2TB drive to the Proxmox Backup Server I have running on my unRAID server. This way all of the storage is local but I have backups of it all.