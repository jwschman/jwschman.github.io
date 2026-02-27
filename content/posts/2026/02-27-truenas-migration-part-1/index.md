+++
title = "TrueNAS CORE to Community Edition: Offsite Backups Before the Migration"
description = "Before migrating from TrueNAS CORE to Community Edition (previously SCALE), I needed offsite backups. Here's how I used restic, Tailscale, and a friend's Ceph cluster to back up all my data including ZFS datasets and Zvols."
date = "2026-02-26"

[taxonomies] 
tags = ["truenas", "homelab", "backup"]

[extra]
cover_image="cover-image.png"
+++

>This is part 1 of a 3-part series. Part 2 covers the migration itself, and part 3 covers the permanent backup solution.

The writing has been on the wall for TrueNAS CORE for several years now.  The introduction of SCALE obviously meant that less attention would be given to CORE, but when jails were no longer officially supported, I knew it was time to leave.  That was two years ago, and I'm finally making the migration now that I have access to offsite backups.  Actually, all development for CORE seems to have ended and SCALE has been renamed to just TrueNAS, with Community Edition being their free offering.

## Why I made the switch

There were actually a number of reasons for me to change from CORE.  As much as I love them, I actually stopped using jails when I built [my Kubernetes homelab](https://github.com/jwschman/homelabo).  I did technically still have a single jail remaining for Plex since the TrueNAS machine was built with Plex in mind, and has a nice GPU in it.  But, that wouldn't be too hard to say goodbye to.

I also liked the idea of being able to natively run docker containers without relying on a VM.  That was also the remedy to my Plex situation.  And it will let me run my HashiCorp vault image on TrueNAS rather than another computer drawing power from the wall just as a docker host.

## Preparation

I knew there was little chance of data loss during this migration, but it did make me a little nervous.  If something went horribly wrong and one of my pools became damaged, that could possibly be years of data lost.  So I used this migration as a chance to finally do offsite backups.  

Fortunately, and the reason I'm doing this now rather than two years ago, is because I have a friend who just recently got fiber internet at home and a homelab significantly larger than mine, and he was glad to put some of his ridiculous amount of storage to use.  Finding the ideal way to backup all my data was a little bit tricky, but I think what I settled on worked very well.

### Planning the Offsite Migration

My friend's system is running Ceph and has plenty of storage, but he doesn't have a public IP for me to connect to, which made things a little interesting.  Tailscale took care of that, though, so next was deciding on how to actually send the data.  Initially I kind of wanted to just do ZFS snapshots to his storage, but that would have required a lot of extra work on his end.  ZFS send/receive requires a ZFS-aware receiver, so he'd need TrueNAS or at minimum a ZFS-capable system to accept it.  That was more than I wanted to ask him to do.  In the end, we went with an S3 endpoint that he gave me access to.  Pretty easy solution for both of us.

Next I had to decide how to actually send the data to the S3 endpoint.  I had a couple ideas at first...

- rsync - simple, ubiquitous, but no encryption and no snapshot management
- rclone - supports S3 natively, has optional encryption, but no deduplication or snapshot history
- restic - snapshots, deduplication, and full client-side encryption baked in

To me the choice is pretty obviously restic.  It gives me easy to manage snapshots with deduplication, and everything is fully encrypted.  It's not that I don't trust my friend with my data, but having the offsite encrypted means I don't have to worry about it.

### ZVol Issue

I have two VMs that I host on TrueNAS: One for development and one to manage my Kubernetes cluster.  TrueNAS stores VM data in Zvols--raw block data rather than files and directories.  Restic backs up files and directories so it has no way to back up a block device directly like it can with my datasets.  Here is how I handled it:

1. Stop the VM
2. Take a snapshot of the zvol to get the point-in-time state: `zfs snapshot pool/vm/zvol@backup` (or, preferably, in the TrueNAS GUI)
3. Export it to an image file: `zfs send pool/vm/zvol@backup > /mnt/pool/zvol-backups/dev.img`
4. Test that the backup is valid: `zfs receive -n pool/vm/test_receive < /mnt/pool/zvol-backups/dev.img` (the -n flag does a dry run without writing data)

Once the images are sitting in a regular dataset, restic can pick them up along with everything else.

## So how did I actually do it?

I know I said that I didn't want to run another VM on TrueNAS, but... I set one up for the initial backup.  I just used it as a temporary way to get all my data offsite while coming up with a better and more permanent solution when the first backup and migration were done.  I'll talk about my actual longterm solution in part three.  Spoiler: it's another VM but much more elegantly handled.  The VM was just a minimal Ubuntu Server install with Tailscale and restic.

In TrueNAS I had to set up a couple NFS shares for the datasets that I wanted offsite, including the new VM backup dataset, and I mounted them all inside the new VM.  Then I just set my environment variables for restic, and ran `restic backup /mnt/tank` in a tmux session and let it go for like... a week.  Just for reference, these are the environment variables restic required:

```bash
export AWS_ACCESS_KEY_ID="my-access-key"
export AWS_SECRET_ACCESS_KEY="super-secret-access-key"
export RESTIC_REPOSITORY="s3:http://my-friends-s3-endpoint.com/offsite-backup"
export RESTIC_PASSWORD="my-password-for-encryption"
```

> it's not an Amazon S3 endpoint but we still need the s3: prefix here

At first there were some Tailscale issues.  Upload speeds were quite slow (less than 10Mbps) when we started, but once a port was forwarded on the other end speeds got much better.  Overall I was sending at around 60-110Mbps.  Still not quite the speed I was hoping for, and it may be because Tailscale is hitting a DERP relay, but we haven't quite figured that out yet.  Still, the speed was fine for an offsite backup.

## Wrapping Up

Once all the data was transferred I did a couple of quick checks to confirm that I could actually retrieve it.  And with that I was ready to start my TrueNAS migration.  I'll talk more about that in part 2.
