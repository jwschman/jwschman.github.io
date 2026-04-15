+++
title = "Truenas Migration Part 3: An Automated and Permanent Offsite Backup Solution"
description = "Setting up an automated nightly offsite backup with restic, Tailscale, and a Rocky Linux VM on TrueNAS."
date = "2026-04-08"

[taxonomies] 
tags = ["truenas", "homelab", "backup", "ai assistance", "self-hosting", "automation"]

[extra]
cover_image="cover-image.png"
+++

Now that I've [migrated to TrueNAS Community Edition](https://jwschman.github.io/posts/2026/03-10-truenas-migration-part-2/) and have an idea for [how to handle my offsite backups](https://jwschman.github.io/posts/2026/03-03-truenas-migration-part-1/) it's time to set up my automated permanent solution.

## The Infrastructure

As I hinted in part 1, I'm going with a VM for this rather than a TrueNAS cloud sync task because I'll be sending the data through Tailscale.  Rather than putting my entire TrueNAS box on the Tailscale network I just wanted a small isolated VM that would handle sending the data, and only that.

The first real decision I had to make was which Linux distribution I'd be running in the VM.  In the end I went with Rocky Linux.  Ubuntu was out because I'm actively trying to move away from it in my personal setup, and Arch didn't make sense for a server I want to set up once and mostly forget about... rolling releases and an infrequently accessed VM are a bad combination.  Rocky made the most sense since I'm likely pursuing RHEL certification in the next few months, and this seemed like a good place to start getting hands-on time with a RHEL-based system.

Once I chose my flavor I just did a minimal installation of Rocky Linux on a VM in Truenas and got to adding the tools I needed, specifically tailscale and restic.  

{% admonition(type="info", title="restic on Rocky Linux") %}
Note: restic is not included in the default repo, so first I had to install Extra Packages for Enterprise Linux with `dnf install epel-release`
{% end %}

I did need a few other utilities that weren't included in the minimal installation like `nfs-utils` to actually do my nfs mounts, and also `tmux` and `vim` for setup and testing.

## What I Wanted

I'm backing up to two different remote restic repositories: one for data and one for media.  I needed the script to run `restic backup` twice, once for each repository.

I also wanted the VM to not be running all the time.  It's not large, but it is a waste of resources to leave running 24/7 when it's usually only going to be running the script for just a few minutes.  So my TrueNAS cron job will need to start the VM, and then when the script completes successfully it will power the VM off.

These backups will generally be pretty quick, but I didn't want them to be running forever if I somehow got some new very large data, so I also want the backups to timeout after two hours.  If a backup doesn't finish within the time limit, it will pick up the following day.

I also wanted notifications sent to Gotify on success or failure.  Once I'm more certain the script is regularly running I'll go back in and remove the notifications on success.

## The Workflow

Before I set up my automation I wanted to do a manual run first to make sure everything worked as intended on the new VM. The steps were:

- mount all my nfs shares from TrueNAS
- connect to the tailscale network
- source my restic environment variables
- run restic backup
- purge old snapshots
- unmount and cleanup

Once I verified that it all worked smoothly I was able to start writing my script.

## The Script

I initially wrote a simple bash script that just did everything from the workflow that I mentioned above.  I have some common functions that I use in scripts for logging and sending notifications to Gotify.  Then I went in and added the extra touches.

The first real thing I had to figure out was error handling.  I wanted to make sure that if anything went wrong I'd get a Gotify notification regardless of where the script failed.  The standard bash way to handle this is with a trap, which lets you run something on any exit.  I set up a cleanup function that unmounts all the NFS shares and sends the notification, and then a trap_handler that calls cleanup and notify on any unexpected exit.

```bash
trap_handler() {
    cleanup
    notify
}

trap trap_handler EXIT
```

I also wanted to make sure that if the script crashed before it even got to set a meaningful message, I'd still get something useful in Gotify.  The way I handled this was initializing `BACKUP_MESSAGE` to an empty string, and then in the notify function I check if it's still empty and set it to "Script failed unexpectedly" if that's the case.

One thing that came up during testing was that I was getting three Gotify notifications per run instead of one.  I fixed it by separating cleanup (unmounting only) from notify (sending the notification).  On a clean run cleanup is called after each backup, notify is called once at the end, and then `trap - EXIT` disarms the trap so it doesn't fire again on exit.  On an unexpected exit the trap calls both and you still get exactly one notification.

Finally, I redirected all output through `tee` so everything gets written to `/tmp/backup-script.log` while still printing to the console:

```bash
exec > >(tee /tmp/backup-script.log) 2>&1
```

This wound up being really useful for debugging because I could check the log after the fact even if I wasn't watching the script run.

## systemd vs tmux

My original plan was to run this script as a systemd service that TrueNAS would trigger over SSH in a cron job.  The idea was that if the SSH connection dropped out unexpectedly the job would continue running.  After a little more thought it seemed a little too extra for a one-shot script on a single purpose VM.

The simpler solution turned out to be having TrueNAS SSH in and start a detached TMUX session running the script:

```bash
ssh $BACKUP_USER@$VM_IP "sudo tmux new-session -d -s backup -- sudo /opt/backup/backup-all.sh"
```

The tmux part isn't strictly necessary, but I wanted to be able to attach to the session to check up on it as it was running, especially during initial testing.

To run the script without entering a password I had to edit sudoers to let `$BACKUP_USER` run sudo without a password, otherwise that command would just hang there forever waiting for a password that would never come.

{% admonition(type="warning", title="tmux and sudo") %}
If you start a tmux session with `sudo`, you also need to attach to it with `sudo`.  Otherwise you'll see that there are no tmux sessions available and wonder why the session never actually started even though you're pretty certain it did.  The session belongs to root and your regular user can't see it.  Obvious in retrospect...
{% end %}

### Automation from TrueNAS

On TrueNAS I just have a short script that runs nightly as a cron job:

```bash
#!/bin/bash
VM_ID=11
VM_IP=192.168.1.64
BACKUP_USER=john

VM_STATE=$(midclt call vm.status $VM_ID | jq -r '.state')

if [ "$VM_STATE" != "RUNNING" ]; then
    midclt call vm.start $VM_ID
fi

until ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no $BACKUP_USER@$VM_IP "echo ready" 2>/dev/null; do
    sleep 10
done

ssh $BACKUP_USER@$VM_IP "sudo tmux new-session -d -s backup -- sudo /opt/backup/backup-all.sh"
```

It starts the VM, waits for it to be available, launches the backup script in a detached tmux session, and exits.  The actual backup script handles everything from there and powers off the VM when it's finished.  The VM is otherwise off, which keeps resource usage low and also means the VM isn't sitting on the network any longer than it needs to be.

{% admonition(type="info", title="Getting the VM ID") %}
To get the ID of the VM I had to run `midclt call vm.query | jq '.[] | {id: .id, name: .name}'` from inside TrueNAS.
{% end %}

## A Few Things That Tripped Me Up

### Newlines in Notifications

I wanted the Gotify notification to show each backup result on its own line.  I was using $'\n' to add newlines when building the message string, but I was putting it inside double quotes:

```bash
BACKUP_MESSAGE="$BACKUP_MESSAGE$'\n'$label: completed successfully"
```

That sent the literal string $'\n' to Gotify instead of a newline. It needed to be outside the quotes:

```bash
BACKUP_MESSAGE="$BACKUP_MESSAGE"$'\n'"$label: completed successfully"
```

### NFS Mounts and Cleanup

I initially had a cleanup loop that unmounted each share individually and removed the directory from `/mnt/`.  But, since this is a single-purpose VM that will never have anything mounted under `/mnt/` other than the backup shares, I simplified it to `umount -a -t nfs4` followed by a check that nothing is still mounted there before doing `rm -rf /mnt/*`.  It's much simpler, and the safety check means I won't accidentally delete data if something didn't unmount properly.  I'd also get a notification in Gotify if there were troubles unmounting.

## The Full Script

The complete script along with the TrueNAS cron script and example .envs is available on [GitHub](https://github.com/jwschman/offsite-backup-script).

## Conclusion

It took me a while to get to part three of this series because I wanted to make sure that my workflow and script were actually fully functional and running for a while before presenting them to the world.

I used Claude to help work through some of the trickier parts of the script, particularly around the trap logic and error handling.  If you're not using AI to help with this kind of thing yet I'd recommend giving it a shot.  It's pretty good at finding edge cases and pointing out things you haven't thought of yet.  You don't have to use all the suggestions it makes, but it's pretty handy and can save lots of time debugging.

I had a few little trip ups with the redundant notifications and nfs mounts, but a little bit of tweaking got things working quite well.

Now that I have this script set up and running nightly on TrueNAS I'm feeling pretty confident that I won't lose my data even if something catastrophic happened.

So now my TrueNAS migration is complete, and my data is safely backed up offsite every night.  I may do a followup with improvements to this script down the line as I use it more, but for now I'm just glad that I have a solid backup solution in place and am running the newest version of TrueNAS Community Edition.