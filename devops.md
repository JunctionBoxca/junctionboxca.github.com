---
title: What the heck is DevOps?
layout: default
created_at: 2012-07-15 12:00:00 +00:00
nocomment:  true
---

<img src="/images/nathan_building_blocks.jpg" alt="Nathan building and deploying" width="100%">

DevOps is a common sense approach to software release cycles. It's an accumulation of best practices and the agreement that software has no business value until it's in the hands of a user. The best way to do that is ruthless automation where deployments become as simple as pressing a button or making a commit. Does it require effort to build and maintain? You bet ya but, it can save many a night of restless sleep and marathon weekend (or week long) deployments.

The name DevOps is attributed to an awesome Belgian by the name of [Patrick DeBois](http://www.jedi.be/blog/2010/02/12/what-is-this-devops-thing-anyway/). Story goes it's derived from the curious union of *agile development* practices being applied to operations. It is commonly described as a "bridge of communication" between developers and operations. Criticise if you will, but when we have our head in code and configuration we often fail to take into account the bigger picture. Ultimately that's what it's all about increased communication across functions and heavy automation.

Common tools of the trade include: 

* provisioning: Cobbler, Kickstart, VeeWee
* virtualization: XEN, VMWare, VirtualBox, LXC
* cloud providers: Rackspace, Brightbox, Amazon
* configuration management: Puppet, Chef, Ansible, CFEngine
* CI: TeamCity, Jenkins, Bamboo
* Command & Control: Go, Fabric, mCollective, misc Doodleware which shall remain unnamed
* dirty hands and scripts.

Jez Humbles book "Continuous Delivery":http://www.continuousdelivery.com/ has a good overview of some of the important points when delivering a project.  It can be summarised as; automate almost everything, don't use bandaids and deal with the pain instead of ignoring it.  My personal addition would be, consider getting rid of that crappy overpriced "enterprise" middleware that's like an albatross around your neck. There's plenty of alternatives out there and big iron isn't necessary for all that much these days.

## Personal Opinion

As I described in my talk on [DevOps Applied](/2012/11/14/devops-geeknight/) I consider there to be 3 fundamental facets to DevOps;

* Build
* Deploy
* Monitor

Some might say I'm overreaching by including build but, hear me out for a moment. If you take nothing else from the teachings of [Mary &amp; Tom Poppiendieck](http://www.poppendieck.com) then I would hope it to be this; *a system is only as strong as it's weakest component*. As a result you must drive back production considerations to where the code is being cut. You could have a well tuned production environment which looks like a product manufactured by Astroglide. However, without a feedback loop that considers the business value the application provides your product is unlikely to hit it's mark in terms of peak performance. Furthermore monitoring of an applications health and business value will empower your organisation with the data required to empirically measure whether changes are doing harm or good. Just think if the next time you deployed an application that you knew whether your users were happy with the changes.  With empirical evidence it becomes much easier to reason about capacity planning, and user satisfaction. Metrics and monitoring are a major opportunity to strengthen the often strained relationship between operations and development. With all of these benefits why wouldn't you invest in what's traditionally fallen under the term of "non-functional" requirements!
