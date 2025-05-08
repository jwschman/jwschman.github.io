+++
title = "Starting my Kubernetes Cluster, Part 1: Introduction"
description = "Documenting the first steps in my migration to Kubernetes"
date = "2024-12-06"

[taxonomies]
tags = ["kubernetes", "homelabo"]

[extra]
cover_image="cover-image.svg"
+++

Over the past several months, I’ve been planning to migrate most of my services off the TrueNAS jails and onto a Kubernetes cluster, since Kubernetes is one of the things I've been focused on studying.  I can see the writing on the wall for FreeBSD and jails specifically in the TrueNAS world, and having a cluster of my own seemed like a good way to both learn Kubernetes and move away from the TrueNAS jails.  Back in the spring and summer I bought two used ThinkCentres off of Yahoo Auctions that I figured would make for good nodes.  I don't need anything beefy for this cluster, and all the files are going to continue to be stored on the TrueNAS server.

Just having the hardware and a vague understanding of Kubernetes wasn't enough to do my migration, though.  I had a very clear vision of how I wanted things to work, and also how I wanted to actually build the infrastructure.

## Automation first

When I'm working on something, I like to be able to wipe the slate clean and restart from scratch if things aren't going quite the way I like.  I don't want to deal with half installed programs that I used once, and then never looked at again.  So for this cluster I wanted to be able to learn as I go, and be able to wipe the servers clean and get them into a prepared state for me to try again.  That meant getting a freshly provisioned OS on physical hardware with as little interaction as possible.  I'll go over how I did this in a separate post in this series.  The end goal for this project is to be able to go from a set of completely wiped computers to a fully functional cluster without much work.

## Keep it simple

Another of my goals for things for this cluster is to keep things as simple as I can.  Things on my TrueNAS server are a little more complicated than I'd like, and that's because I had very little idea what I was doing as I initially set it up, and definitely didn't have a plan.  And since several of the pieces are built in weird ways, I had to work around them, making things even more weird.  I want to avoid that completely with this Kubernetes cluster.  It's also one of the reasons why I want everything to be automated.  If something gets out of hand, I'll hopefully be able to scrap it and find an easier alternative way to do it.  So far, that goal has been achieved.

So those are the two main points I've been focusing on while going through this build.  I'd like to do separate writeups for all of the individual steps that I took along the way to get to my functioning cluster.  At the moment, here is my vague plan:

- Provisioning the hardware
- Preparing the OS for Kubernetes, including installing the container manager
- Installing and preparing Kubernetes
- initializing the cluster with `kubeadm` and joining the worker node
- NFS storage on TrueNAS
- Getting all those services from jails going

Things may change wildly in the future as this build comes along and I learn more about Kubernetes, but that's all part of the journey I'm on, and also why I'm trying to document it.

---

## Update on 5/8/2025

So things did change, although *wildly* isn't really the adjective I'd use to describe them.  "Adjust moderately" might be a better phrase.  As expected things did change as I learned Kubernetes, and so did the scope of this project.  Most of those planned writeups I listed above will likely be consolidated into two or three articles in the near future, and now I have a list of new things to talk about.  I guess I should start working on those...
