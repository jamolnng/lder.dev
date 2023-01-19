---
title: "Day 11: Updating this website quirks"
date: 2022-06-21 12:00:00 -600
categories: [homelab, 100-days-of-homelab]
tags: [software, jekyll]
mermaid: true
---

This will be a short post about my struggle updating to the newest version of this website template. Believe it or not, I did not create it myself. It's a template, and a good one at that from [https://github.com/cotes2020/jekyll-theme-chirpy](https://github.com/cotes2020/jekyll-theme-chirpy).

The version I was running was 5.1.0 while 5.2.1 was released 4 days ago at the time of writing this post.

In order to have good build times, even with a Jekyll cache, I found out that it is best to have a `Gemfile.lock`. However, when updating, I had to delete my old `Gemfile.lock` so I needed a new one. Now I do not actually build this website on my local machine to test it, I have a Drone CI instance that builds it and pushes it to a staging site where I can view it to make sure it looks right. If it looks good I then use Drone CI to promote it to production which pushes it to Github and Github rebuilds it and publishes it on this website.

The problem I found is that you need Jekyll to generate this file and I could not generate it on my computer. I could just easily install Jekyll but I decided that was too much effort so simple just added a `cat Gemfile.lock` command to my Drone pipeline and copied that. Easy as that. Once I commited and pushed this file it dropped my build times from 60 seconds to 7 seconds. Then I simply removed the command since I did not need it anymore.

Now it took me a while because as you may have guessed, I am not that familiar with Ruby or Jekyll so it was a bit of trial and error. I was deciphering error messages and changing the build pipeline before I got it right.

You can see my pain in this chart of my builds

![Build Times Diagram](/assets/img/posts/2022-100-days-of-homelab/day011/build-times.png)

But in the end it worked and now you and I are on version 5.2.1, great!