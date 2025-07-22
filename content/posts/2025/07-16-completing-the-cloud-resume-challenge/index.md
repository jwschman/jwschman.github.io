+++
title = "Completing the Cloud Resume Challenge"
description = "My three week journey completing the Cloud Resume Challenge"
date = "2025-07-16"

[taxonomies] 
tags = ["cloud resume challenge", "aws", "terraform"]

[extra]
cover_image=""
+++

> ***TLDR***: I completed the [Cloud Resume Challenge](https://cloudresumechallenge.dev/).  [Check out my live site here](https://jwschman.click) or [explore the github repo for all the resources here](https://github.com/jwschman/cloud-resume-challenge).

Last month while looking for jobs I stumbled upon the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) and thought that it was a great idea.  Doing it would give me a somewhat structured course for demonstrating the skills that I've learned over the last year as well as give me a chance to play with some things that I'm not so familiar with.  So I gave it a shot and three weeks later here we are.

## What it is

The Cloud Resume Challenge is a number of steps and requirements with the end goal of building a static website hosting your resume.  

The challenge asks you to:

- Host a static HTML/CSS resume with AWS S3 and Cloudfront
- Build a hit counter with a lambda function and DynamoDB
- Tie everything together with an API gateway and JavaScript
- Implement a CI/CD pipeline for all of these resources.

It doesn't tell you how to do any of these steps, but instead is more of a set of guiderails to get you to the final goal.  

## How I completed it

I decided to go with the suggested "chunks" in the book which provides a little bit of structure by grouping some of the steps together.  I also decided to go with the AWS version I already had the AWS Cloud Practitioner Certificate.  I completed all of the chunks in about 20 hours spread over three weeks aside from the final chunk, which is writing a blog post.

I also set up a couple ground rules when I started.  I wanted this work to be all my own, and I also wanted to actually both learn new things and apply my knowledge as I went.

These are the rules that I set up:

- Zero GenAI:  If I had a question or wanted suggestions, I had to search for it rather than just ask for the answer.
- No Full Guides:  I actually didn't check, but I assume there are full guides for prebuilt Cloud Resume Challenge projects.  That seems like it would completely defeat the purpose of this challenge.  Specific guides such as "How to setup cloudfront in Terraform" are OK, but "Full Cloud Resume Challenge" guides aren't.

## Making the challenge my own

Because the challenge is a set of goals rather than a guide it encourages you to modify it to your needs.  Here are some of the things I did a little bit differently than the guide suggested:

- Terraform Everything:  From the first step I took I wanted everything I did to be done with IaC, and I have also been learning Terraform lately so the timing worked out perfectly.  This definitely upped the difficulty because I couldn't just go into the AWS Management Console and click my way to what I wanted, but it got my hands dirty with IaC and specifically Terraform.
- Golang instead of Python:  Since I started learning tech last year one of my focuses has been getting comfortable with Golang so I saw this as another chance to use it.  The challenge asks you to make a Python script for your lambda function but I decided to write it in Go, which brought its own difficulties but nothing too troublesome.

## Final Product

The actual site is [here](https://jwschman.click) at [jwschman.click](https://jwschman.click).  And here's a cool little diagram I made on [draw.io](https://draw.io) that shows most of the services I used for the project.

![diagram.png]

If you're interested in learning about how I completed the challenge, I'll explain it chunk by chunk next.

## Chunk 1: Frontend

I've enjoyed building little html websites since high school so this chunk was fun.  I did have to do various searches for `css a attributes` or `centering text in div` or whatever, but I wound up with something that I think looks simple but also pretty good.  Recently I've really liked the [Dracula Theme](https://draculatheme.com) so I went with that for my colors.

Setting up the actual infrastructure on AWS was a little more difficult, specifically the cloudfront distribution and DNS, but I managed to get them working with terraform without too much trouble.  Permissions were probably the hardest point here because a guide had used `PrincipalArn` not `SourceArn` in the IAM policy for the bucket, but once I got that sorted out things worked perfectly and I was feeling pretty good.

### Time Spent on this Chunk: 8 hours

### Resources Used

- https://codepen.io/emzarts/pen/OXzmym
- http://lospec.com/palette-list/dracula-standard
- https://denisgulev.com/static-website-with-aws-s3-cloudfront-and-terraform/
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
- Terraform AWS Provider Documentation

## Chunk 2: API

This is where I made my big departure from the original directions and went with Golang rather than Python.  There are a lot of resources that I found for writing Golang functions that could communicate with AWS resources, but it seems to be a pretty complicated process that isn't super beginner friendly.  [You can see the actual Golang function here](https://github.com/jwschman/cloud-resume-challenge/golang).  After a bit of trial and error I had a working Lambda function, deployed with Terraform, communicating with a DynamoDB database.

"Communicating" was a little bit of a hard part, not because I didn't understand how to get it to work, but because of a typo I made.  I couldn't get the function to call GetItems from the table, and figured it was a permissions issue because that was what the errors were saying.  I spent the good part of an hour messing with permissions before I eventually found out that my permissions were asking for `GetItme` not `GetItem`.  Oops.  Once I found that things were working and I linked the lambda function in with an API Gateway and was done with this chunk.

### Time Spent on this Chunk: 6 hours

### Resources Used

- https://www.thedevbook.com/deploy-go-aws-lambda-function-using-terraform/
- https://hevodata.com/learn/lambda-dynamodb/
- https://medium.com/@jamesscarr6/how-to-deploy-an-aws-go-lambda-function-via-terraform-in-under-5-mins-2025-be9d9b2decfa
- https://www.geeksforgeeks.org/devops/create-aws-api-gateway-with-terraform/

## Chunk 3: Front-end / back-end integration

At first this chunk seemed pretty easy.  I don't know any JavaScript but doing a simple API call didn't seem like it would be hard, and it wasn't.  Getting that API call to work in a web browser, however, was more than I expected.  I had never even heard of CORS until I saw the error message in the console of Firefox.

***CORS SCREENSHOT HERE***

CORS took me by surprise, but I found a couple guides online that helped me through fixing it, and once I understood what I needed to implement it actually wasn't so bad.

As for testing, I just did a couple simple tests using Cypress Tests as recommended by the Cloud Challenge Guidebook.  Because the hit counter function is so small I didn't want to take a lot of time finding and writing tests for it, so I kept this part extremely simple.  I know there was a lot more I could have done here (it's almost as if testing were its own field unto itself) but I decided to move on from this after just a little bit of work.

### Time Spent on this Chunk: 3 hours

### Diagram at this point

[This is where a simple diagram of all my resources will be at this point in the challenge]

### Resources Used

- https://www.reddit.com/r/javascript/comments/5blh60/displaying_json_content_in_html/ 
- https://basescripts.com/how-to-fetch-and-display-api-data-on-your-website
- https://itsyndicate.org/blog/configuring-cors-and-integration-on-aws-api-gateway-using-terraform/

## Chunk 4: Automation / CI

This was probably the easiest chunk for me to do since I had built everything in Terraform from the start.  The biggest part of this step was reorganizing everything I had set up into modules, and cleaning up unused and redundant variables.  I'm sure things could be cleaner, but it all works and is fairly clean.

This is also the chunk where I decided to switch to a remote state for Terraform which I also set up on AWS using a separate terraform root.  Nothing fancy, but it cleaned things up and helped with the automation.

So now whenever I push changes to either the frontend website or lambda function in my github repo, those changes are automatically applied to the AWS resources through github actions.  I could also have it apply if I were to make any changes to the main Terraform resources, but at the moment I think it's best to keep it isolated to those things, and manage the rest of the resources locally.  Because of the remote state both GitHub and my local machine can manage it, which is exactly what I wanted.

### Time Spent on this Chunk: 3 hours (mostly cleanup)

### Resources Used

- Just some Google searches for doing Terraform apply as github actions

### Chunk 5: The blog

Here I am now writing a blog post about how I felt the challenge went and what I did during it.  Overall the difficulty level was about what I expected.  Some parts such as setting up the actual AWS infrastructure in Terraform were quite straightforward, and some parts such as writing the Lambda function in Go and dealing with CORS weren't as simple.  Fortunately there are countless resources available and even if something isn't exactly what I needed, I was able to mix and match to get the end results that I desired.  I wouldn't say it was difficult, but it did take a good amount of time just because it was my first time setting up a cloud project with this many interconnected services.

If I wanted to spend more time on this project I would have done several of the additional mods, specifically the DevOps and security focused modules.

### Final Thoughts

This challenge really gave me a chance to tie together a lot of the things that I've learned in the last year.  It also let me show concrete proof that I actually can do this with both the public website and the IaC that I provide in my public GitHub repo for it.

If you're interested in doing the Cloud Resume Challenge yourself check it out at [The Cloud Resume Challenge](https://cloudresumechallenge.dev/)

### Total Time Spent: 20 hours over about 3 weeks
+++
title = "Completing the Cloud Resume Challenge"
description = "My three week journey completing the Cloud Resume Challenge"
date = "2025-07-16"

[taxonomies] 
tags = ["cloud resume challenge", "aws", "terraform"]

[extra]
cover_image=""
+++

> ***TLDR***: I completed the [Cloud Resume Challenge](https://cloudresumechallenge.dev/).  [Check out my live site here](https://jwschman.click) or [explore the github repo for all the resources here](https://github.com/jwschman/cloud-resume-challenge).

Last month while looking for jobs I stumbled upon the [Cloud Resume Challenge](https://cloudresumechallenge.dev/) and thought that it was a great idea.  Doing it would give me a somewhat structured course for demonstrating the skills that I've learned over the last year as well as give me a chance to play with some things that I'm not so familiar with.  So I gave it a shot and three weeks later here we are.

## What it is

The Cloud Resume Challenge is a number of steps and requirements with the end goal of building a static website hosting your resume.  

The challenge asks you to:

- Host a static HTML/CSS resume with AWS S3 and Cloudfront
- Build a hit counter with a lambda function and DynamoDB
- Tie everything together with an API gateway and JavaScript
- Implement a CI/CD pipeline for all of these resources.

It doesn't tell you how to do any of these steps, but instead is more of a set of guiderails to get you to the final goal.  

## How I completed it

I decided to go with the suggested "chunks" in the book which provides a little bit of structure by grouping some of the steps together.  I also decided to go with the AWS version I already had the AWS Cloud Practitioner Certificate.  I completed all of the chunks in about 20 hours spread over three weeks aside from the final chunk, which is writing a blog post.

I also set up a couple ground rules when I started.  I wanted this work to be all my own, and I also wanted to actually both learn new things and apply my knowledge as I went.

These are the rules that I set up:

- Zero GenAI:  If I had a question or wanted suggestions, I had to search for it rather than just ask for the answer.
- No Full Guides:  I actually didn't check, but I assume there are full guides for prebuilt Cloud Resume Challenge projects.  That seems like it would completely defeat the purpose of this challenge.  Specific guides such as "How to setup cloudfront in Terraform" are OK, but "Full Cloud Resume Challenge" guides aren't.

## Making the challenge my own

Because the challenge is a set of goals rather than a guide it encourages you to modify it to your needs.  Here are some of the things I did a little bit differently than the guide suggested:

- Terraform Everything:  From the first step I took I wanted everything I did to be done with IaC, and I have also been learning Terraform lately so the timing worked out perfectly.  This definitely upped the difficulty because I couldn't just go into the AWS Management Console and click my way to what I wanted, but it got my hands dirty with IaC and specifically Terraform.
- Golang instead of Python:  Since I started learning tech last year one of my focuses has been getting comfortable with Golang so I saw this as another chance to use it.  The challenge asks you to make a Python script for your lambda function but I decided to write it in Go, which brought its own difficulties but nothing too troublesome.

## Final Product

The actual site is [here](https://jwschman.click) at [jwschman.click](https://jwschman.click).  And here's a cool little diagram I made on [draw.io](https://draw.io) that shows most of the services I used for the project.

![diagram.png]

If you're interested in learning about how I completed the challenge, I'll explain it chunk by chunk next.

## Chunk 1: Frontend

I've enjoyed building little html websites since high school so this chunk was fun.  I did have to do various searches for `css a attributes` or `centering text in div` or whatever, but I wound up with something that I think looks simple but also pretty good.  Recently I've really liked the [Dracula Theme](https://draculatheme.com) so I went with that for my colors.

Setting up the actual infrastructure on AWS was a little more difficult, specifically the cloudfront distribution and DNS, but I managed to get them working with terraform without too much trouble.  Permissions were probably the hardest point here because a guide had used `PrincipalArn` not `SourceArn` in the IAM policy for the bucket, but once I got that sorted out things worked perfectly and I was feeling pretty good.

### Time Spent on this Chunk: 8 hours

### Resources Used

- https://codepen.io/emzarts/pen/OXzmym
- http://lospec.com/palette-list/dracula-standard
- https://denisgulev.com/static-website-with-aws-s3-cloudfront-and-terraform/
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution
- Terraform AWS Provider Documentation

## Chunk 2: API

This is where I made my big departure from the original directions and went with Golang rather than Python.  There are a lot of resources that I found for writing Golang functions that could communicate with AWS resources, but it seems to be a pretty complicated process that isn't super beginner friendly.  [You can see the actual Golang function here](https://github.com/jwschman/cloud-resume-challenge/golang).  After a bit of trial and error I had a working Lambda function, deployed with Terraform, communicating with a DynamoDB database.

"Communicating" was a little bit of a hard part, not because I didn't understand how to get it to work, but because of a typo I made.  I couldn't get the function to call GetItems from the table, and figured it was a permissions issue because that was what the errors were saying.  I spent the good part of an hour messing with permissions before I eventually found out that my permissions were asking for `GetItme` not `GetItem`.  Oops.  Once I found that things were working and I linked the lambda function in with an API Gateway and was done with this chunk.

### Time Spent on this Chunk: 6 hours

### Resources Used

- https://www.thedevbook.com/deploy-go-aws-lambda-function-using-terraform/
- https://hevodata.com/learn/lambda-dynamodb/
- https://medium.com/@jamesscarr6/how-to-deploy-an-aws-go-lambda-function-via-terraform-in-under-5-mins-2025-be9d9b2decfa
- https://www.geeksforgeeks.org/devops/create-aws-api-gateway-with-terraform/

## Chunk 3: Front-end / back-end integration

At first this chunk seemed pretty easy.  I don't know any JavaScript but doing a simple API call didn't seem like it would be hard, and it wasn't.  Getting that API call to work in a web browser, however, was more than I expected.  I had never even heard of CORS until I saw the error message in the console of Firefox.

***CORS SCREENSHOT HERE***

CORS took me by surprise, but I found a couple guides online that helped me through fixing it, and once I understood what I needed to implement it actually wasn't so bad.

As for testing, I just did a couple simple tests using Cypress Tests as recommended by the Cloud Challenge Guidebook.  Because the hit counter function is so small I didn't want to take a lot of time finding and writing tests for it, so I kept this part extremely simple.  I know there was a lot more I could have done here (it's almost as if testing were its own field unto itself) but I decided to move on from this after just a little bit of work.

### Time Spent on this Chunk: 3 hours

### Diagram at this point

[This is where a simple diagram of all my resources will be at this point in the challenge]

### Resources Used

- https://www.reddit.com/r/javascript/comments/5blh60/displaying_json_content_in_html/ 
- https://basescripts.com/how-to-fetch-and-display-api-data-on-your-website
- https://itsyndicate.org/blog/configuring-cors-and-integration-on-aws-api-gateway-using-terraform/

## Chunk 4: Automation / CI

This was probably the easiest chunk for me to do since I had built everything in Terraform from the start.  The biggest part of this step was reorganizing everything I had set up into modules, and cleaning up unused and redundant variables.  I'm sure things could be cleaner, but it all works and is fairly clean.

This is also the chunk where I decided to switch to a remote state for Terraform which I also set up on AWS using a separate terraform root.  Nothing fancy, but it cleaned things up and helped with the automation.

So now whenever I push changes to either the frontend website or lambda function in my github repo, those changes are automatically applied to the AWS resources through github actions.  I could also have it apply if I were to make any changes to the main Terraform resources, but at the moment I think it's best to keep it isolated to those things, and manage the rest of the resources locally.  Because of the remote state both GitHub and my local machine can manage it, which is exactly what I wanted.

### Time Spent on this Chunk: 3 hours (mostly cleanup)

### Resources Used

- Just some Google searches for doing Terraform apply as github actions

### Chunk 5: The blog

Here I am now writing a blog post about how I felt the challenge went and what I did during it.  Overall the difficulty level was about what I expected.  Some parts such as setting up the actual AWS infrastructure in Terraform were quite straightforward, and some parts such as writing the Lambda function in Go and dealing with CORS weren't as simple.  Fortunately there are countless resources available and even if something isn't exactly what I needed, I was able to mix and match to get the end results that I desired.  I wouldn't say it was difficult, but it did take a good amount of time just because it was my first time setting up a cloud project with this many interconnected services.

If I wanted to spend more time on this project I would have done several of the additional mods, specifically the DevOps and security focused modules.

### Final Thoughts

This challenge really gave me a chance to tie together a lot of the things that I've learned in the last year.  It also let me show concrete proof that I actually can do this with both the public website and the IaC that I provide in my public GitHub repo for it.

If you're interested in doing the Cloud Resume Challenge yourself check it out at [The Cloud Resume Challenge](https://cloudresumechallenge.dev/)

### Total Time Spent: 20 hours over about 3 weeks
