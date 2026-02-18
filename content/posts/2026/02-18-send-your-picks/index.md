+++
title = "Send Your Picks: I Over-Engineered My Friends' Football Pool"
description = "A month-long journey from Excel spreadsheets and group chats to a self-hosted Go, SvelteKit, and Supabase webapp"
date = "2026-02-18"

[taxonomies] 
tags = ["kubernetes", "homelab", "go", "ai assistance", "postgres", "supabase", "claude code"]

[extra]
cover_image="cover-image.png"
+++

> TLDR: I spent a month building a full-stack web app so my friends would stop forgetting to send their NFL picks.  Here's a link to the [GitHub repo](https://github.com/jwschman/send-your-picks).

## Background

My friends and I do a yearly NFL against-the-spread picking game.  It's mostly an excuse for us to trash talk each other throughout the season, and then all get together at the end to have a nice dinner and make fun of the loser.  I'm making it sound meaner than it actually is... it's all in good fun.

It was all run through email, a group chat, and an Excel spreadsheet.  It was a lot of work and error-prone, and someone always forgot to send their picks on time.  We looked into options to make it easier but were never able to settle on something that suited exactly what we wanted.  So I did the normal thing and spent a month building this app so the commissioner would never have to say *send your picks* again.  I did some upfront planning... drew up data models and figured out the basic flow.  But it wasn't nearly enough, as I'd find out later.

## What it Actually Does

Send Your Picks is a webapp that lets users pick their games against the spread from the NFL lineup each week.  Users sign up and make their picks, and the app keeps track of points, weekly winners, and season standings.  Week creation, scoring, standings, and next week creation are all handled automatically by the app.

## The Stack

Ok, maybe it's overengineered and could have been handled by a shared spreadsheet, but doing it this way was way more fun and also a much better learning experience for me.

### Backend

I wrote a Go API server with the Gin framework, using about 40 endpoints (so far).  This is by far the largest backend I have written to date and I learned a ton through the experience.  More on that below.  The backend handles all the actual logic and SQL queries, as well as scraping external APIs for game information.

### Database

I started out wanting to use Postgres and decided on Supabase after initial research.  Supabase is pretty great and handles JWT creation as well as offering a free hosted option.  My group will work well within the free tier so I decided to delegate the database rather than self hosting it, which is my usual instinct.  In the future should the free tier disappear, or if I just wanted more control, I could easily go with a self hosted supabase instance.

### Frontend

I don't really do frontend... I mean, I can write some basic HTML and CSS, but nothing modern or even remotely fancy.  So this is where I decided to go the GenAI route.  I'm not fully sold on using GenAI for all coding yet, but it does seem pretty capable of writing frontend code.  I decided to go with SvelteKit for the frontend because I initially found a guide for auth using Supabase and SvelteKit and never changed from that.  Supabase works well with these frontend frameworks and can even have data directly queried, but since I don't trust my frontend security skills, I decided to have all that business live in the Go API server.  All queries, role-based access, and everything else is handled in Go, not the frontend.  The frontend just gets information from the backend and shows it in pretty ways.

I have to say, I'm very happy with how the frontend turned out.  It was well worth the $20 for the month of Claude Code to get.

## Using It (Future tense)

I finished the initial development at exactly the right time, the week of the Super Bowl.  So... we haven't had a chance to use it in production yet.  I've run through seasons with dummy data and multiple users and everything works great, but my users haven't had a real chance to try it out and break it yet.  The 2026 pre-season will be my chance to find any issues and fix them before the actual season begins.

I don't think they will realize the work and technology behind our little game, but I think it's pretty cool.  We went from a janky Excel spreadsheet and group chat to a self-hosted full-stack webapp.  I even added some fancy little things like profile pictures, badges for winners/losers, and eventually achievements that the commissioner can award.  Who knows what else will get added when we actually start using it.

## The Interesting Part

The backend is where I spent most of my time and where I learned the most.  Before this project I'd never written auth middleware (the whole first week of development was figuring this out), built a state machine, or looked at an SQL query more complicated than a basic SELECT.

First was the auth, which was mostly me reading half a dozen guides and finding out what worked for me.  What I settled on was Supabase-issued JWTs validated by middleware on the Go side.  Every API route requires some form of authorization (basic user, commissioner, or admin) and the middleware checks the role from the JWT claims before the request ever hits the handler.

From there I just went with what made sense: I couldn't make games without weeks, and weeks without seasons, so I started there and worked through them all.  Around 30 endpoints in, I realized I had no idea what I'd already built, and wound up writing a planning/tracking document just to keep track of it all.  Lesson learned the hard way.

As I mentioned, my SQL skills weren't great, so I had GenAI handle most of the queries for me at first.  As I saw more of them, I was able to write and tweak them to my liking.  I'm actually quite interested in learning more SQL, so if you know any good resources or courses please let me know!

Once I had my users, seasons, and weeks, it was time to make the games.  Having the commissioner input games one by one seemed tedious and just as error-prone as the original spreadsheet, so I wanted this to be automatic.  I found an API that had all the information I needed within a free tier: [BallDontLie](https://www.balldontlie.io/).  Parsing the response and building game records from it worked very well, but it doesn't include spreads.  So... I scrape a second external API just for those.  Inelegant, but it works.  After games are played I hit BallDontLie again for final scores, match them against the spreads and each user's picks, and then scoring can begin.

But I wanted all of this to be automatic and difficult to mess up, so I built a state machine with an 8-state lifecycle for the weeks: `draft -> games_imported -> spreads_set -> active -> played -> picks_results_calculated -> scored -> final`.  Overkill... I know.  But it's a nice solution.  Most transitions happen automatically (import games, import scores, calculate pick results, compute standings) and the commissioner only has to step in twice: once to approve the spreads, and again to activate the week for picks.  Eventually a Kubernetes cron job will kick off the automated transitions, so the whole thing mostly runs itself.  If the commissioner needs to tweak spreads before activating, or skip the external spreads API entirely, they can.  Hell, if the external API providing spreads works well, I'll be able to remove the need for the commissioner to do anything.

## Wrapup

Is it bloated?  Possibly.  Is it unnecessary?  Definitely.  Is it cool?  Very much.

If I were to start again from scratch (maybe v2 next year?) things would be much cleaner with this experience under my belt, but I don't regret a single decision I made along the way.  I learned how to design usable data models, build API routes and state machines, write more complex SQL queries, and most importantly: plan everything out.

Aside from all the technical skills, the importance of planning was my biggest takeaway from this project.  I had done what I thought, at the time, was a lot of planning at the start, but it was nowhere near a complete picture of what I actually needed.  I knew going in that software projects require considerable planning... it's almost as if there's entire positions dedicated to it, and Send Your Picks really gave me an impression of what it actually entails.  Going in and just adding things piece by piece is fun in the moment but quickly leads to an unmaintainable and impossible to understand mess.  You've got to start with a plan.

In the end, while this does solve a problem for my friends and me, I mainly built it for myself.  I took on a project that was bigger than anything I had tried before and succeeded at it.  Even if we decide that the emails and spreadsheet were better, I built this (with help) and now I have the confidence to try more projects.  I already have a few ideas rolling around in my head, and now that I won't really have to touch this again until the summer I can get started on them.

Check out the [GitHub repo](https://github.com/jwschman/send-your-picks) if you want to see the code.
