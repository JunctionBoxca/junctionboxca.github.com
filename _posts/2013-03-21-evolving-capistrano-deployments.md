---
title:      Evolving Capsitrano Deployments
created_at: 2013-03-21 12:00:00 +00:00
layout:     default
published: true
description: Is capistrano the best way to handle your deployments? You may want to consider an alternative approach for modern rails apps.
keywords: capistrano, deployment, continuous delivery
---

Let's start with a little history. [Capistrano](https://github.com/capistrano/capistrano) was built many moons ago on the sunny, sandy beaches of Hawaii by [Jamis Buck](http://weblog.jamisbuck.org/) (some artistic license regarding location). It's use as described in the README;

<blockquote>
"Capistrano was originally designed to simplify and automate deployment of web applications to distributed environments, and originally came bundled with a set of tasks designed for deploying Rails applications."

</blockquote>
As outlined above Capistrano's goal was simple; Provide a mechanism that allows Rails apps to be deployed simply, reliably and in a manor that is repeatable (the fact that it had a nice syntax and API was a bonus). The success and adaptation to non-Rails apps is a testament to Capistrano achieving it's goal. Capistrano works best with interpreted languages but, I've seen it shoehorned for use with compiled languages as well. So if Capistrano is so amazing what criticism could I possibly have to suggest that it needs evolution? Well here's a quick list that I'll cover in detail below;

-   [Repetitive compilation](#repetitive_compilation).
-   [Compile time dependencies on production](#compile_dependencies_on_prod).
-   [Promiscuous production nodes](#promiscuous_prod).
-   [Conclusion](#conclusion)

### Repetitive Compilation

A modern rails app is no longer (if ever) a purely interpreted language. It's a hybrid using an interpreted language for it's core and compiled assets on the periphery in the form of C-based Gems and the Asset Pipeline. The reality is all of this compilation takes time and there's little black magic to avoid that fact. How much time will vary between applications but, let's use ~5m per server group for easy calculation (many of the apps at [uSwitch.com](http://www.uswitch.com/) take about that long including checkout). Now assume the following multi-staged production deployment process;

`Canary -> DC1 -> DC2`

Given each stage is run in serial the standard Capistrano workflow requires a minimum of ~15mins (excluding any QA) to complete a deployment. A na&iuml;ve optimisation would be to pre-compile the assets locally but, please **do not** for the sake of reproducablity! If you're using a [C.I.](http://www.martinfowler.com/articles/continuousIntegration.html) box I would strongly encourage you to compile the assets there instead and package them in a zip or tarball.

### Compile time dependencies on production

Next up is compile time dependencies on production. Generally speaking most companies I've worked with have an increasing number of nodes as you approach production (excluding dev). The simple question becomes what's easier to update; your handful of CI boxes or N number of production nodes? What will cause less grey hair? Oh and did I mention less packages being installed == faster auto-scaling? Sure you could build a base AMI, VM snapshot, etc including all of the dependencies but, it's a little heavy handed and hardly meets the "Infrastructure as Code" that I like to achieve. Jez Humbles book on [Continuous Delivery](http://continuousdelivery.com/) covers off a number of other valuable reasons not to compile on your servers such as fingerprinting and traceability but, give the book a read for yourself.

### Promiscuous Production Nodes

The final point is once you're compiling and packaging on C.I. you can eliminate the need to forward ssh-agents and/or SCM credentials. This eliminates a window of access to your repositories (and possibly more). Considering many companies deploy and run their apps as the same user, a compromise in your app would make pretty trivial to exploit the forwarded agent to gain access to other resources (e.g. hosts, repositories, etc).

### Conclusion

While I wouldn't necessarily suggest this effort for a team that's running only a few servers, I would highly recommend moving to a package based approach if you're considering auto-scaling or have a large number of servers. A good resource to start with this approach is Philip Potters article on [RPM, Ruby and Bundler](http://rhebus.posterous.com/rpm-ruby-and-bundler). You may not want to create system packages but, it does give you a leg up on where to start even if you only package using zips or tarballs. One final note that I should mention `bundler install --standalone` is you're friend (thanks [@zaargy](https://twitter.com/zaargy))!

Edit: (2013-03-22) Fix some spelling errors.
