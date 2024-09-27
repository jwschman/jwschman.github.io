+++
title = "Zola First Steps"
description = "Trying out zola, the kita theme, figuring out how to write pages"
date = "2024-07-08"

[taxonomies] 
tags = ["zola", "testing"]
+++

For the moment I'm going with Zola to make this static site.  It was a bit of a learning curve but I seem to be getting the hang of how it makes the pages, and what I need to do to have them appear on the site.

## Hosting on Github pages

Though I could set up a jail on my TrueNAS server to host the site, it seems better at the moment to try out using Github pages for this project.  It gives me a chance to learn about Github some more, and also get acquainted with Github actions.  Following the guide on the zola site was actually pretty straightforward for this part and I had the site up and running in no time.  Running and filled with content are very different things.

## Themes

When I was originally messing with Zola inside a FreeBSD jail I had some trouble with the themes.  Hosting inside a jail and accessing it messed up the directories which in turn messed up the content being used by the theme.  I found it easier to just run Zola directly on my laptop.

## Directory Structure

I think I have a pretty understandable directory structure set up, but without spending some time working on things I'm not exactly sure what will make sense in the future.  Right now I have separate directories for posts and all other content, and the post directory has subdirectories labeled by year.  I likely don't need the yearly subdirectories, but I'd rather not have one huge (I'm sure) directory filled with every post that I've ever written.  

I also have another directory for guides, but I'm debating if I should just post all guides as regular posts, and hit them with the "guide" tag.  That seems like it would accomplish the same thing.

A similar thing I'm wondering about is the posts section.  Does having that and the archive page seem redundant?  It kind of does to me...  I have a feeling I'll be consolidating all of these into just tags and archive.

## Problems

I actually had a little bit of trouble setting up the subdirectories, but once I set

```markdown
transparent = true
```

to the frontmatter of a _index.md in the subdirectory, it snapped into place and worked.

I did have other troubles figuring out how everything worked, but now that I have a few days of just messing around I seem to understand how to do things.
