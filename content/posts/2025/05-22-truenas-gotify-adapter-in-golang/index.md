+++
title = "TrueNAS Gotify Adapter in Golang"
description = "A way to get TrueNAS alerts in Gotify"
date = "2025-05-22"

[taxonomies] 
tags = ["truenas", "github", "go", "kubernetes", "open-source", "programming", ]

[extra]
cover_image="gotify-test-alert.png"
+++

> ***TLDR***: I put up a public GitHub repo with an app that lets you get TrueNAS alerts inside Gotify.  [Check it out here](https://github.com/jwschman/truenas-gotify-adapter-golang).

Since passing the CKA, I've been taking a short break from focused study and have been messing around with a few new things.  One of those things is Gotify because I wanted a central place to see all my notifications.  I don't like getting email notifications, or even really getting unimportant notifications on my phone.  Gotify works great for this, but TrueNAS doesn't have a native way to send alerts to Gotify, so I started looking for a workaround.  This led me to a Python script that does exactly that, [on GitHub](https://github.com/ZTube/truenas-gotify-adapter).  It worked great and was exactly what I wanted, but another thing I've been trying out is getting back into programming in Go.  So I thought it would be a good exercise to port this python script into Go, and that's exactly what I did.

And then, as usual, the scope ballooned a bit from there.  The original python script was run as a Docker container, so mine should too... right?  That's easy enough.

And if it's running as a container, I should run it in Kubernetes... right?  Guess I should write some manifests.

And then if I'm building Docker images, this will be a good chance to work with some CI and have GitHub actions take care of it for me and automatically publish it to Docker Hub.  It took a little bit of learning since it was my first experience with it, but it did exactly what I wanted.

And if I'm going through all of this and it's working this well, then I should just make it all open-source and publicly available.

And so here we are.  [TrueNAS Gotify Adapter Golang](https://github.com/jwschman/truenas-gotify-adapter-golang) is available on GitHub.

I'm going to skip the setup in this post since it's all available in [the documentation](https://github.com/jwschman/truenas-gotify-adapter-golang/blob/main/readme.md) but it's very easy to set up and get going.

Now I’ll actually see my TrueNAS alerts again, since I won’t have to log in to the dashboard just to check them. I barely open the TrueNAS UI anymore now that everything’s running in Kubernetes.

So now one more little project is done.  Next on the list is working more with Prometheus...
