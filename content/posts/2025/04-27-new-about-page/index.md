+++
title = "New About Page"
description = "Site updated!"
date = "2025-04-27"

[taxonomies] 
tags = ["about", "certifications", "studies", "zola"]

[extra]
cover_image="about_screenshot.png"
+++

After a long break to focus on studying for the CKA, I'm finally giving this site some attention again.  The first update was to my [About page](/about/).  I’ve made quite a few changes, including a list of technologies I’ve grown comfortable with over the years and a new certifications section.  I'm really glad that I wrote that little shell script for creating new posts since it came in quite handy with remembering how to handle the front matter.

I've mentioned in a different article that I'm not super familiar with CSS, but I managed to put that page together [using this simple example that I found](https://codepen.io/jh3y/pen/dyKXmpB) and some experimentation.  I think it turned out pretty well.

I also ran into a few Zola quirks again, mostly from my lack of using it for several months.  I have posts separated in different subdirectories by year, and since this is the first post of 2025, I forgot that I needed to add a `_index.md` inside the new `2025` directory and include `transparent = true` in the front matter.  Remember to document the things you do, because you *will* forget them half a year later.  I should actually add creating that _index.md into the newpost script since it already creates the directory for the new year.

Anyway, I have a number of posts in the works, including several that I started writing over the past few months but never finished.  Most are about Kubernetes, developing my homelab, and studying for the CKA..
