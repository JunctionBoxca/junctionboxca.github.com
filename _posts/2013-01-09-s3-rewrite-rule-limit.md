---
title:      S3 Rewrite Rule Limit
created_at: 2013-01-09 12:00:00 +00:00
layout:     default
description: Amazon S3 rewrite rules are limited and not explicitly defined in the documentation where you would expect. Find out the limit in this article.
keywords: amazon, s3, devops, nginx, rewrite 
tags: aws devops
---

Amazon has been a boon for a number of organisations interested in automation and [DevOps](/devops.html) but, it's not all roses. There's plenty of unexpected gotchas with their servies. The other day I was migrating some static content from old infrastructure to S3. Along the way I discovered that there appears to be an undocumented limit on number of [rewrite rules](http://docs.aws.amazon.com/AmazonS3/latest/dev/HowDoIWebsiteConfiguration.html#configure-bucket-as-website-routing-rule-syntax) you can use with an S3 bucket. The magic number that I've found so far?

A measly 20!

When you exceed that number you'll get an error stating;

“You can't have more than ROUTING\_RULE\_COUNT Routing Rules on the same website configuration.”

I've worked around the limitation by fronting it with our NGinx load balancers and defining the rules there. For personal websites that use Jekyll, I could see this as a bit of a let down though. Here's hoping they expand the count in the future!
