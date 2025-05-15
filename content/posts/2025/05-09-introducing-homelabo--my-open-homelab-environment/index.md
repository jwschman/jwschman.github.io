+++
title = "Introducing HomeLabo: My Open Homelab Environment"
description = "A look at open-sourcing my homelab Kubernetes cluster"
date = "2025-05-09"

[taxonomies]
tags = ["homelabo", "homelab", "github", "kubernetes", "open-source"]

[extra]
cover_image=""
+++

> **TL;DR**: I made my homelab config repo public.  You can find it [here](http://github.com/jwschman/homelabo).

One of my big goals after getting the CKA was making the github repo for my homelab Kubernetes cluster public.  I thought this would be a good way for other people to see what I've done and how I do things.  It was also a good chance for me to write better documentation and guides for what I had done.  While not *everything* is fully documented yet, I feel pretty good about what I have now, and I hope to write the missing documentation as I work on those respective parts of HomeLabo.

## Preparation and Challenges

The first and most important thing I needed to consider when making my entire Kubernetes cluster's configuration public was security.  My cluster is entirely declarative and the GitHub repo is the source of truth, so *everything* in the cluster is also in the repo.  That meant I had several secrets, passwords and tokens sprinkled in throughout the various directories and inside several helm `values.yaml` files.  This led me down a rabbit hole of external secrets providers and I eventually settled on using self-hosted [Hashicorp Vault](https://developer.hashicorp.com/vault) along with [External Secrets Operator](https://github.com/external-secrets/external-secrets) for Kubernetes.  I went through every file in the repo, pulled out all the secrets, and put them into Vault.  Then I created ExternalSecrets objects for the cluster to use.  It's actually a pretty slick way of handling secrets in the homelab.

The second part of preparation was going through and making sure everything was not only documented, but documented in the right place.  While I had documented and taken notes on a lot of what I did with this project, it was scattered around in various files and in different places.  I've done a lot of cleaning and organizing to get things in place, but there is still more work to be done.  But now that I have a basic system in place it will be easier to keep things organized.

Finally, I had to write a `readme.md` that actually described what my HomeLabo project was about.  It's kind of a little manifesto about what I was thinking when I built HomeLabo and my values for it going forward.  It was actually really fun to lay everything out and write about it.  Because of the nature of HomeLabo (learning and experimentation as well as daily use) the readme will need to be updated as HomeLABO evolves.

If you're curious about HomeLabo or the way I do things, you can check out the GitHub repo at <github.com/jwschman/homelabo>.
