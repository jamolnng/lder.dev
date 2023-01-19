---
title: unRAID Notifications with ntfy.sh
date: 2022-10-06 13:00:00 -600
categories: [homelab]
tags: [unRAID]
---

unRAID comes with a lot of ways to receive notifications. From email and discord to slack and telegram. However, my preferred notification system is [ntfy.sh](https://ntfy.sh) which it does not have support for. Hopefully one day unRAID has a better way to set up custom notification systems like via user scripts or something similar, but for now this is how I figured out how to do it.

### Setup

First you'll need a ntfy.sh instance set up: [https://ntfy.sh/docs/install/](https://ntfy.sh/docs/install/)

Then, in unRAID go to settings then notifications. In the `Notification Settings` section find `Notification entity` and then enable unRAID to send notifications through `Agents` for all of the notifications you want to receive.

### Notification Script
Via some digging, I found that unRAID will run every script in `/boot/config/plugins/dynamix/notifications/agents/` when a notification is sent via agents. This means we can easily insert a script into this folder to be run when notifications are sent. For ntfy.sh my script looks like this:

```bash
#!/bin/bash
curl -u "user:pass" \
  -H "Title: ${SUBJECT}" \
  -H "Tags: unRAID" \
  -d "Event: ${EVENT}
Subject: ${SUBJECT}
Description: ${DESCRIPTION}
Importance: ${IMPORTANCE}
Time: $(date '+%Y-%m-%d %H:%M:%S')

${CONTENT}" \
  https://ntfy.domain.tld/unRAID
```
{: file="/boot/config/plugins/dynamix/notifications/agents/ntfy" }

And that's basically it. Look at the ntfy.sh docs for more information on configuring that and how to receive the notifications.