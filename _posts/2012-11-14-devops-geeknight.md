---
title:      DevOps Applied
created_at: 2012-11-14 12:00:00 +00:00
layout:     default
keywords: devops tools, geek night, build, deploy, monitor
description: A 45m talk on the tools and practises used in DevOps from build to deployment to monitoring.
tags: devops
---

### A 3 step technical redux

This was my first public talk on DevOps, hope those of you that attended enjoyed it. Apologies folks started a new job and have really been dragging my feet on this. Hope to add more on my train rides home to describe the tools of the trade that I've used as DevOps consultant.

### Build

#### Code

Build Info Page

-   created at
-   build number
-   SCM revision
-   requested at (helps identify caching proxies)

Health Check Pages

-   No passwords or connection strings
-   No passwords or connection strings
-   No passwords or connection strings, I've said it 3 times don't make me say it again!
-   You may want **short** caching here to prevent DoSing constrained services, but generally should report on any dependencies (e.g. key value stores, db's, etc).
-   Consider using a microformat or expose it as JSON as well as a page.

<!-- -->

-   Puppet (DSL) - my preference
-   Chef (Ruby)
-   Pallet (Clojure)
-   cfEngine (DSL)
-   Ansible (Python)

#### Test

-   puppet parse (e.g. find puppet -name \\\*.pp | xargs -n100 puppet parser validate)
-   puppet-lint (Ruby Gem)
-   erb syntax check
-   Vagrant

#### Package

-   simple compressed file (zip, tarball)
-   structured compressed file w/ metadata (jar, war, etc)
-   system package (dpkg, rpm, dmg, etc)
-   generate build info at this stage (revision, creation date, build number)

#### Publish

-   web-dav
-   maven repository
-   file share

### Deploy

#### Push/Pull Package

-   scp
-   file system mount
-   torrent

#### Backup/Migrate

-   Highly dependent on your data store and size.
-   NoSQL doesn't mean "No migrations", it may feel that way but, you'll just accumulate debt in your code.

#### Install

-   Start with one node to verify it will even work.
-   Only install to a subset of nodes. Pick a number that you're confident when pulled that the rest of your nodes can handle peak traffic.

#### Verify

-   build info matches expected (e.g. did the deployment work as expected?)
-   health check page.
-   critical user flows (exercise connectivity to dependencies, everything else should've been caught in upstream tests)

### Monitor

#### Collect

-   collectd
-   graphite
-   ganglia

#### Analyse

#### Readjust

### Presentation Resources

-   [Live Stream Recording](https://new.livestream.com/accounts/1960766/events/1673605)
-   [Slide Deck](/media/pres/2012-11-14-DevopsApplied.pdf)

Updated:

-   2013-01-10 - Add bullet points for Build and Deploy.
-   2013-01-09 - carve out the general sections.
