---
title:      Clojure Testing
created_at: 2016-08-02 12:00:00 +00:00
layout:     default
published: true
description: Clojure start-up time can be expensive especially when using ClojureScript. This article is a quick post to aggregate what I use to improve the testing feedback cycle in Clojure.
keywords: clojure, testing, repl
tags: clojure testing
---

Clojure start-up time can be expensive especially when using ClojureScript. Here's a couple items I've used to cut down start-up test execution time down:

Run all namespaces

    lein test

Run a specific namespace

    lein test :only cc.jbx.blog

Run a test case

    lein test :only cc.jbx.blog/test-rendering-post

Run in the REPL

    lein repl
    (use 'clojure.test)
    (defn test-blog []
    """
    This is just a little helper function to make reloading and running the tests more efficient.
    """
    (require 'cc.jbx.blog :reload-all)
    (run-tests 'cc.jbx.blog))

    (test-blog)
