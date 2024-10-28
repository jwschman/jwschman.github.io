+++
title = "Jailhouse Roll Call"
description = "Creating a Custom Status page for TrueNAS Jails"
date = "2024-10-28"

[taxonomies] 
tags = ["go", "programming", "truenas", "api integration", "ai assistance", "portfolio"]

[extra]
cover_image="jrc_screenshot.png"
+++

## Background

I have a lot of jails running on my TrueNAS server.  Checking their status through the GUI or by ssh using `iocage list` isn't difficult, but I wanted a simple, on-demand page that could give me a quick overview of each jail's status from anywhere on my local network.  I'm also in the process of becoming more familiar with programming in Go, so I thought making a page with all my jail information that I could just load up would be a fun and useful project.

## Figuring it out

I initially went a difficult and roundabout route which involved sshing directly into the server, running `iocage list`, grabbing everything from stdout, parsing that, and saving it as a struct to eventually be displayed on a simple webpage.  It was good programming practice, but it felt excessive for such a straightforward task, especially since I was pretty sure there was a TrueNAS API that I could use.  After a little bit of research I found documentation about the API and how to make the `/jails` call, and from there things got much more simple.

## Outside help

Since I didn't have much experience locally serving static sites, I did some quick research and found a great blog that explained everything I needed to know at <https://www.alexedwards.net/blog/topic> specifically the page [Serving Static Sites with Go](https://www.alexedwards.net/blog/serving-static-sites-with-go) and [Golang Response Snippets: JSON, XML and more](https://www.alexedwards.net/blog/golang-response-snippets).

Following those guides I was able to very quickly get the page up and running, displaying all the information that I wanted.

## Making it look nice with AI assistance

I did want the page to look better than just simple black text on white space, but I have very little experience with css.  A friend recently showed me a program he made with the help of GitHub copilot, and he seemed very pleased with the results.  Since I don't have a copilot subscription I decided to try ChatGPT to see if could help.  I pasted in my index.html template and gave a brief description of what I wanted, and the css it generated was perfect.  It even improved upon my original idea by making even and odd rows colored differently.  I also decided to push it a little bit and asked for some Javascript so that the columns could be sorted on click.  Again, no problem.

## Deploying JRC

At the moment I have the program running in yet another jail on my TrueNAS server.  I think that makes it jail number 15.  Ideally it wouldn't be running on the same server that it's pulling information from, but that's the reality of my current setup.  I do have plans though...

## Conclusion

This project was a fun way to dive deeper into Go programming and explore some new tools.  It also showed me how handy AI can be for quickly handling tasks that I'm unfamiliar with.

## References and Tools

- Alex Edwards' Blog Archive: <https://www.alexedwards.net/blog/topic>
- TrueNAS API Reference: <https://www.truenas.com/docs/core/api/>
- ChatGPT: Assisted with generating CSS and JavaScript for styling and functionality
