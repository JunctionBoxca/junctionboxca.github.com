---
title:      Feature Flags 101
created_at: 2011-05-28 12:00:00 +00:00
layout:     default
keywords:   Continuous Delivery, feature flags
description: Feature Flags aid Continuous Delivery by allowing the release of incomplete or untested features. See the simple example in this post.
tags:       cd ruby
---

Committing to mainline is an important feature of CI and always keeping your mainline deployable is a requisite for Continuous Delivery. So what's an easy way to maintain code quality and get new features in? Feature Flags and Branching by Abstraction!

So what exactly does this look like?

Let's start with a simple function that outputs your name:

    def name
      @first_name
    end

Now we want to change the function but it's going to be significant in someway, how would we achieve that? The simplest way would be to introduce a binary variable that allows flow control. I'm not a big fan of this option as it can potentially require a lot of overhead to wire in configuration files to it.

    def name
      return name_flag_name2 if @enable_name2
      @name
    end

    def name_flag_name2
      # TBD
    end

That's a simple on/off approach for rolling out a new feature what if you want to do canary releases? Well you'll need something that handles a little more logic:

    def name
      return name_flag_name2 if @features.enabled?(:enable_name2, @user_account_type)
      @name
    end

Here are a few thoughts to consider during it's implementation;

-   Do you want to control your features during release or use live decisioning (e.g. A/B testing)?
-   How do you want to manage the configuration of those features?
-   Where will the feature flag values be stored and will it affect page performance?
-   When should a feature be considered complete? (hint: has the flag been removed?)
