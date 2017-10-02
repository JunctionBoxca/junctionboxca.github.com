---
title:      Clojure Testing
created_at: 2016-08-02 12:00:00 +00:00
layout:     default
published: true
description: Clojure start-up time can be expensive especially when using ClojureScript. This article is a quick post to aggregate what I use to improve the testing feedback cycle in Clojure.
keywords: clojure, testing, repl
---

Clojure start-up time can be expensive especially when using ClojureScript. Here's a couple items I've used to cut down start-up test execution time down:

Run all namespaces

    <code>lein test
    </code>

Run a specific namespace

    <code>lein test :only cc.jbx.blog
    </code>

Run a test case

    <code>lein test :only cc.jbx.blog/test-rendering-post
    </code>

Run in the REPL

    <code>lein repl
    (use 'clojure.test)
    (defn test-blog []
    """
    This is just a little helper function to make reloading and running the tests more efficient.
    """
    (require 'cc.jbx.blog :reload-all)
    (run-tests 'cc.jbx.blog))

    (test-blog)
    </code>
