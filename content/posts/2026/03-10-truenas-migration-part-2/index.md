+++
title = "Truenas Migration Part 2"
description = "The actual migration from TrueNAS CORE to Community Edition.  Here's how it went, including fixing a pool import error, migrating Plex from a jail to a Docker container, and sorting out VM networking"
date = "2026-03-10"

[taxonomies] 
tags = ["truenas", "homelab", "backup", "plex"]

[extra]
cover_image="cover-image.png"
+++

>This is part 2 of a 3-part series. Part 1 covered an initial offsite backup, and part 3 covers the permanent backup solution.

In [my previous post about this topic](https://jwschman.github.io/posts/2026/02-27-truenas-migration-part-1/), I talked about how I backed up all the data from my TrueNAS server to an offsite server with the intent of migrating from the FreeBSD-backed TrueNAS CORE to the Linux-backed TrueNAS  Community Edition.  The data was all successfully sent off to my friend's server and I was ready for the migration.

## Preparation

To actually do the migration I had to update my TrueNAS CORE to the latest version.  I was only one version behind so this was a quick update.  Even with a small update, though, it's always a good idea to download the latest version of your TrueNAS config.

Before actually beginning I went through [the checklist provided in the TrueNAS documentation](https://www.truenas.com/docs/scale/24.04/gettingstarted/migrate/migrateprep/).  After checking the things that related to me I also made sure to screenshot the configurations for my network, VMs and a few other things just in case.

## Upgrade Options

Before performing the migration I made sure to check the [official TrueNAS Migrating CORE to SCALE guide](https://www.truenas.com/docs/scale/24.04/gettingstarted/migrate/migratingfromcore/) to see the correct way to do it.

There were two options for the Community Edition install.  Just fresh installing the latest version or upgrading to 24.04 and stepping through the updates one by one to the latest version.  Since my TrueNAS server lives in a crawlspace with no monitor, and I didn't want to dig it out from under the house, I opted for the second option.  And if something went wrong I could always pull the server out if necessary.

## The Actual Migration

Honestly the upgrade went as smoothly as one could have hoped for.  

In the TrueNAS GUI I just set the release train to TrueNAS SCALE 24.04 and let it do its thing (after downloading my latest config again).  After a few minutes I refreshed the page and was treated with the TrueNAS Scale login page.  It looked strange and different and I kind of didn't like it since I've been on the FreeBSD version since 2020, but I was glad to see it.

And then when I logged in I was greeted with a big scary error message that one of my pools hadn't imported.  I'm not sure what caused it, but the fix was straightforward.  I found the pool import option in the GUI, imported it, and everything came back exactly as it was.  All my data was there and safe, all my settings were as I left them, and things were working.  Then I just stepped through the updates in the GUI again (I think it was 3) to get to the latest version of TrueNAS.

## The VM Situation

The way TrueNAS Community Edition handles networking is different than CORE, so I had to change the networks on my VMs.  It was a pretty simple process:

- Create a bridge interface in the TrueNAS GUI with the server's physical network interface as a bridge member
- Move the IP configuration from the physical interface to the bridge
- Change the VMs NIC to the new bridge interface
- Log in to the VMs and update netplan to use the new bridge (both were Ubuntu Server VMs)

> One thing to make sure is that you set the bridge's IP to be different than the old interface's IP or you will get very weird and very annoying network issues that you'll spend 15 minutes fighting with.

## Plex: From a Jail to a Container

As I mentioned before, I still used Plex in a Jail on TrueNAS Core and would need to migrate that to a container.  This was actually quite simple because past me was smart and set the Plex config directory to a dataset on one of my pools.

I didn't really want to use the Plex app from the "Discover" apps page because it's very outdated, so I wrote a very simple Docker compose myself and used that.

```yaml
services:
  plex:
    container_name: plex
    environment:
      - PUID=972
      - PGID=972
      - PLEX_CLAIM=YOUR-CLAIM-CODE # use https://account.plex.tv/claim to get a new claim code
    image: plexinc/pms-docker:latest
    network_mode: host
    restart: unless-stopped
    volumes:
      - /mnt/tank/apps/plex/config:/config
      - /mnt/tank/media/:/mnt/media:ro
```

The only small problem I had with this was that config directory for the container version wasn't the same as the config directory I had installed on TrueNAS CORE.  It was nested two directories deeper, so I had to do a little bit of shuffling.

I just had to move the contents of `/mnt/tank/apps/plex/config/Plex Media Server` to `/mnt/tank/apps/plex/config/Library/Application Support/Plex Media Server` and then all my settings, libraries, and watched titles were available in the new instance.

## NFS Hiccup

I use NFS CSI in my Kubernetes homelab for backing up Kubernetes data to my TrueNAS. After the migration I noticed some of my NFS mounts seemed to have gone stale, and pods that depended on them were hanging and unable to read or write. Rather than dig into the root cause, I just restarted the Kubernetes nodes one by one. It worked, so I didn't investigate further. Not the most elegant solution but it was quick and easy and I didn't mind the (very short) downtime in my cluster.

All the NFS shares that I had set up previously on TrueNAS CORE were all preserved in the new version and I didn't actually have to change any settings.

## Conclusion

I probably didn't need to wait as long to perform this migration as I did, but I'm glad that I've finally done it.  But, I am a little sad to no longer be running FreeBSD on any of my machines anymore.  It's really where I learned self-hosting and Unix fundamentals.  I also loved my jails and am sad that I don't have any running anymore.  Containers are cool and all... but jails were special.

I'm also glad that I didn't have any data issues with the upgrade.  And even if I had, the offsite backup had me covered.

In the next part of this series I'll write about my actual offsite backup solution that I went with to make sure that the data I'm saving is up to date.
