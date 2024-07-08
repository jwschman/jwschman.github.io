+++
title = "Zola First Steps"
description = "Trying out zola, the kita theme, figuring out how to write pages"
date = "2024-07-08"
+++

# Zola First Steps

*07-08-2024*

For the moment I'm going with Zola to make this static site.  It was a bit of a learning curve but I seem to be getting the hang of how it makes the pages, and what I need to do to have them appear on the site.

## Hosting on Github pages

Though I could set up a jail on my TrueNAS server to host the site, it seems better at the moment to try out using Github pages for this project.  It gives me a chance to learn about Github some more, and also get acquainted with Github actions.  Following the guide on the zola site was actually pretty straightforward for this part and I had the site up and running in no time.  Running and filled with content are very different things.

## Themes

When I was originally messing with Zola inside a FreeBSD jail I had some trouble with the themes.  Hosting inside a jail and accessing it messed up the directories which in turn messed up the content being used by the theme.  I found it easier to just run Zola directly on my laptop.
