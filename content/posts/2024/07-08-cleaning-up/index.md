+++
title = "Cleaning up Zola"
description = "More organization, and figuring out how I want things to be"
date = "2024-07-13"

[taxonomies] 
tags = ["zola", "testing"]
+++

So I got rid of the posts and guides sections at the top.  It made the most sense to me for them to not be there.  They were redundant since I have tags and the archive page.

Aside from that I haven't done much with the site yet.  I'm still more focused on LFCS and CKA stuff at the moment, but there is some work that I'd like to do for this page as well.

Specifically I want to write a quick script that will make markdown files in the posts directory with the correct front matter, specifically the date.  I'm not sure if I'd also like to have it automatically add tags at creation, or if that's something I should add after the fact since a post may not go in the direction I originally intended it to.  I assume most of my posts on here will be mostly freeform prose aside from guides, so a post may shift drastically from its original content as I'm typing it.

Another thing I'd like to do is add featured images to these posts.  I know it can be done, and it likely won't be difficult, but it's something that I need to do a little bit of research on.

And number three, I want to learn how to use the admonition shortcode included in the theme I'm using.  To demonstrate, it's this...

{% admonition(type="tip", title="tip") %}
The `tip` admonition.
{% end %}

I know there's a lot of them, and it seems like something that would be very handy while writing guides.

So that's the three things I intend to work on in the future.

I guess that's all for now.
