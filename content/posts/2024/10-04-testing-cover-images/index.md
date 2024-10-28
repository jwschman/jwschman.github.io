+++
title = "Zola Cover Images"
description = "Testing out cover images as well as centering images in posts"
date = "2024-10-04"

[taxonomies] 
tags = ["zola", "testing"]

[extra]
cover_image="slime.jpeg"
+++

I had a bit of trouble getting this cover image to work, and even more trouble finding any kind of documentation for how to do it.  What I eventually did was edit templates for pages and change the url for the images to...

```text
src="{{ get_url(path=page.colocated_path, trailing_slash=true)}}{{page.extra.cover_image }}"
```

The main reason it wasn't working was because of where I place my images, and wanting to colocate all images with the actual post.  I'm sure it's not the best way to do things, but it makes things easy for me, and it works for now.

---

I also didn't like how images don't seem to want to be center justified so I wrote a shortcode with its own .css just for the images.  

Here's the image.html shortcode

```html
<p>
    <img
    src={{get_url(path=page.colocated_path, trailing_slash=true)}}{{src}}
    alt="{{src}}"
    class ="center">
</p>
```

and this is the very simple imagestyle.css that I added to the static folder

```css
.center {
    display: block;
    margin-left: auto;
    margin-right: auto;
}
```

And here's the end result with the same image that I used for the cover image...

{{ image(src="slime.jpeg") }}

achieved with this shortcode

```text
{{/* image(src="slime.jpeg") */}}
```

{% admonition(type="note", title="note") %}
If you want to show a shortcode but not have Zola to render it, you will need to escape it by typing {{/* (shortcode contents) */}} 
{% end %}

Again, this certainly isn't the way to have done this, and there's probably a much better way to have done it, but I'm having a lot of trouble finding examples and documentation for using Zola.  It's making me consider trying out a different static site generator, but now that I have things working I'm not sure if that will be necessary.
