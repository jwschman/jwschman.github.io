+++
title = "I Got My CKA"
description = "How I prepared for and passed the Certified Kubernetes Administrator exam"
date = "2025-05-16"

[taxonomies] 
tags = ["cka", "kubernetes", "study", "certifications", "kodekloud"]

[extra]
cover_image="cka.png"
+++

Ever since I decided to shift into IT about a year ago, passing the CKA was my primary goal and I finally did it a couple weeks ago.  It's extremely refreshing to have actually achieved it, and now I feel like I have a number of new things that I can focus on.  This post will describe how I prepared for the test, the detours that I took while preparing, and finally the actual exam itself.

## Prep for the CKA

### KodeKloud CKA & Linux Foundation (LFS258)

I've mentioned in [previous posts](/tags/kodekloud/) that I like to use KodeKloud for online courses.  Specifically I like the hands-on labs they provide.  Learning from reading documentation and watching videos is helpful, but getting real experience is the best way for me to learn a new technology.  It's actually how I teach my classes at school.  KodeKloud's CKA course seems to be widely recommended online and was a great resource overall, though I did find the labs a bit on the easy side this time around.

In addition to the KodeKloud course I also worked through the [Linux Foundation Kubernetes Fundamentals (LFS258)](https://trainingportal.linuxfoundation.org/courses/kubernetes-fundamentals-lfs258) course, which a friend generously gifted me.  This course dives deeper into how Kubernetes works and covers the exam materials more thoroughly.  It also approaches hands-on learning in a different way.

With the KodeKloud course you are able to get going right away with their prebuilt labs.  You can start running `kubectl` commands immediately without worrying about setting up your own cluster.  One of the best implementations of this is that they are able to provide intentionally broken clusters, which is great practice for troubleshooting.  I felt that this was probably the biggest advantage of the KodeKloud labs.  Being able to go in and fix something (without actually messing up your own setup) is a great experience.  

In contrast, LFS258 takes a deeper, more DIY approach by having you build your own cluster at the beginning of the course.  It's a great way to learn but may be difficult for someone without much Linux experience.  Actually, for both of these courses (and the CKA in general) experience with Linux is essential.  I'm very glad that I decided to do the [LFCS](/posts/2024/10-03-completing-the-lfcs/) beforehand as it gave me a solid foundation to build on.

### Anki

Once again I used Anki flash cards to remember a lot of the concepts and commands.  One piece of advice that I got early on was to use imperative commands while actually taking the CKA test and the flash cards helped out with that a lot.  It is often much simpler to run an imperative command and output it into a .yaml file than look up how to write the manifest in the [kubernetes.io](https://kubernetes.io) documentation.  Every morning I went through my anki deck while drinking my coffee and it became a little ritual.  Having a good routine for this is extremely helpful so the cards don't just pile up.

### Study Schedule and Timeline

I usually spent between one and three hours every weeknight working on these courses and it took me about 5 months to get through.  This would have been made shorter if I had been able to spend more time studying each day and also hadn't gotten distracted by my homelab.  Speaking of which...

## Distractions and Detours

About a month in to studying Kubernetes I got antsy and decided to start moving all of my homelab over from FreeBSD jails on my TrueNAS to an actual Kubernetes cluster.  And since the point of this cluster was also for learning Kubernetes and more Linux experience I wanted to do things correctly rather than bumbling through them.  I actually wrote a few articles about it already on this page [(tags for some of the posts here)](/tags/kubernetes/) and definitely learned a lot.  At the end I had a fully built three node Kubernetes cluster set up with `kubeadm` and managed by ArgoCD.  When I came back to the courses I found that I had moved past them in experience but I still needed the foundational knowledge to reinforce my skills.  I definitely wouldn't have been able to pass the courses with just my practical experience.

## Practice for the Exam

### Killer Shell Exam Simulator

Registering to take the CKA gives you access to two Killer Shell exam simulators and it would be ridiculous not to use them.  Everything I've heard online and from a friend about Killer Shell is that the practice tests are noticeably harder than the actual tests.  So when I completed the first Killer Shell simulator and got a high score I was feeling pretty confident and booked my actual exam pretty much right away.  The questions were definitely on the tough side but not anything I couldn't do after completing the CKA prep courses.

The second simulator, however, felt much more difficult and made me feel a bit worried about the actual test.  It also didn't help that about 15 minutes into starting the simulator we had a pretty sizeable earthquake here with several large aftershocks and I became distracted with things around the house.

### KodeKloud Practice Tests

The KodeKloud CKA course offered a few practice tests at the end of the course and they were also quite helpful, though not nearly as difficult or thorough as the Killer Shell tests.  They were also great for making Anki flash cards from.  Having a large list of possible questions and scenarios let me really fill out the deck at the end.

### Alta3 Research CKA Exam Questions & Solutions Youtube Videos

I stumbled on these videos about a week before I took the test and they were very helpful giving me more of an idea of what to expect, as well as quick ways of completing the tasks.  He runs through all of the tasks that he prepared and shows you exactly what to do for them.  Great resource right before taking the test.

## Test Day

From previous experience taking Linux Foundation test I knew to prepare my room and clean out pretty much everything in sight of the camera.  I didn't want to get called out for anything and have to reschedule.  It also meant my room was really clean after the test which was nice.

As for the test itself, most questions were straightforward and aligned with what I had studied.  The only problem was that there were a ***LOT*** of tasks and only two hours to complete them.  You really need to know your way around the Kubernetes documentation pages as well as how to do those imperative `kubectl` commands to get everything done in time.  I was very glad I got that advice about knowing how to do things imperatively because without it I don't think I would have gotten a passing score.  All of the Kubernetes content on the test was covered in both of the prep courses I took so I felt prepared but if someone were to go in knowing minimal Linux they would definitely have troubles with some of the tasks.  Simple things like output redirection and knowing how to use `grep` are pretty important.

The test allows you to flag difficult questions to come back to and that was very helpful for going through and completing the quick and tasks first and coming back to the ones that would require more thought later.  As I was finishing my final task, troubleshooting a node that was down, I fixed the problem and ran `kubectl get nodes` and right as I saw that the node was listed as Ready my screen changed and I was informed that I had reached the time limit.  Things couldn't have possibly been closer, and I didn't have any time to go back and check my answers like I did on the LFCS, but I was finished and awaiting the results.  Almost exactly 24 (very long) hours later I got an email saying that I had passed the exam along with links to my certification details.

## Advice for Passing

I did this for my [LFCS post](/posts/2024/10-03-completing-the-lfcs/) so I probably should here as well.  Actually my advice here is very similar to the advice on that post.

Do the KodeKloud and killer.sh labs and practice tests.  They'll get you prepared for how the test will actually go.  Also, Anki for remembering commands will help with your speed on test day.

The big difference between the LFCS and CKA is that you are allowed access to the Kubernetes website during the CKA so you need to be able to quickly navigate it and know where to look for things that you want.  Knowing what page to be on and doing ctrl+f to look for "kind: pod" will help significantly.

Also, as I mentioned before, knowing how to do the imperative commands also helps a lot.  Being able to run something like `kubectl run podname --image=whatever --dry-run=client -oyaml >> pod1.yaml` to quickly create a pod manifest for editing or `kubectl create serviceaccount my-service-account` is faster and less prone to errors than copying it from the documentation.  Again, anki helps here.

## Final Thoughts and What's Next

It's a great feeling to complete a goal that you set for yourself a year ago.  I had to take other steps to get here, such as completing the LFCS and migrating my homelab to Kubernetes, but I did it.  

Like I mentioned before, the actual test was tough.  The content itself wasn't surprising or especially difficult, but completing all of the tasks within the time limit definitely made things difficult.

As for what's next, I haven't really decided.  After passing I just took a week off of everything and enjoyed not needing to study for anything.  Then I spent some time on the homelab which you can see in my previous and upcoming posts here.  But now that I've had that little bit of time off I'm ready to get back into the habit of studying.  KubeCon Tokyo is also coming up in less than a month...

## Resources and Links

- [KodeKloud CKA Certification Course - Certified Kubernetes Administrator](https://learn.kodekloud.com/courses/cka-certification-course-certified-kubernetes-administrator)
- [Linux Foundation Kubernetes Fundamentals (LFS258)](https://trainingportal.linuxfoundation.org/courses/kubernetes-fundamentals-lfs258)
- [Killer Shell CKA Simulator](https://killer.sh/cka)
- [Alta3 Research CKA YouTube Series](https://www.youtube.com/watch?v=rP-W3Tv3plw)
