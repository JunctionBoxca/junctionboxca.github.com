---
title:      Clojure/Bitbucket Pipelines
created_at: 2016-08-19 12:00:00 +00:00
layout:     default
published: true
description: Bitbucket Pipelines is out and in Beta. I recently received an account but with so many distractions I didn't have an opportunity to dig into the offering until recently. Bitbucket Pipelines only supports a handful of languages directly but I'll show you how to quickly get Leiningen building your project using the Clojure Docker image.
keywords: clojure, ci, bitbucket, docker
tags: ci clojure docker
---

CI is more than nice to have. In this day and age I consider it manditory and one of the first things to setup with a new project. Bitbucket recently launched a beta called [Bitbucket Pipelines](https://bitbucket.org/product/features/pipelines) which as you can guess targets CI/CD Pipelines. Atlassian were gracious enough to give me access and I'll show you how to get a Clojure project running in short order.

I have a private Clojure/ClojureScript project that I wanted building in CI, I'll assume you have a working project too. For repositories that have Bitbucket Pipelines available you'll see a new icon on the left side of the project. Clicking the "Pipelines" icon will take you to a so called [Blank Slate](https://gettingreal.37signals.com/ch09_The_Blank_Slate.php) view. Here you'll be prompted with an option of choosing your language with links to the configuration guide and integrations. When you click on the dropdown you'll note that Clojure is not an option but, fear not kind reader Docker images appear to be the basic building blocks of Pipelines. All it took was quick search on Docker Hub and I was able to find a [Clojure Image](https://hub.docker.com/r/library/clojure/tags/). I'm using lein 2.6.1 in my project. You can select the appropriate tag for your project as far back as Leiningen 2.4.3. The clojure images clock in around 250MB so they're not tiny but not huge either thanks to being based on the Alpine base image.

To get up and running with a Clojure build simply select "Other" for the programming language and click "Continue". One thing that seemed odd was that you have to "Copy Configuration" before you can continue. I'm guessing this is because the Pipeline service is only loosely linked to Bitbucket but its a bit of a superfluous step. On the next screen you'll be presented with the web based editor where you can paste the following yaml:

    image: clojure:lein-2.6.1

    pipelines:
      default:
        - step:
            script:
              - lein test

Presumably you can skip the UI and get your builds running by simply adding a yaml file named bitbucket-pipelines.yml to the root of your repository. Either way once committed to the Bitbucket repository you should see your build happily kick off. My project is a Clojure/ClojureScript app and appears to take 1-3m to build. Not too far off from local builds and I certainly won't complain for a free offering. I might explore vendoring all of the dependencies to reduce the build time. For now the service seems to work well and I look forward to exploring how the CD aspect works.
