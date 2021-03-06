---
title:      One REPL to Rule Them All
created_at: 2016-09-11 12:00:00 +00:00
layout:     default
published: true
description: A typical clojure invocation will gobble up close to 500MB. If you're running a ClojureScript project that'll be 1G for figwheel and a Clojure nREPL. I think I've found an improved workflow that reduces that memory pressure.
keywords: clojure, testing, repl
tags: clojure testing
---

For the last few weeks I've had 3 Clojure related terminals:

1. lein trampoline run
2. lein trampoline figwheel
3. lein trampoline repl

I'm sure Clojure veterans are screaming, "Oh the humanity!!! why?![](?)"

I've increasingly been unsettled with this workflow on my low spec (4GB RAM) MacBook Air it's brutal in terms of memory consumption. Trying to pinch every ounce of performance out of my Air I think I might've found a better (read less memory intensive) workflow:

1. lein trampoline repl.
2. import and start clj project.
2. import and use figwheel-sidecar.

This gets everything into one repl and reduces the memory overhead of my previous workflow by about 1/2 the memory usage.

I suspect there will be all sorts of new issues that I'll need to address but I'll take them for a lower memory footprint.

In excrutiating detail the start up is (see the [sidecar wiki](https://github.com/bhauman/lein-figwheel/wiki/Using-the-Figwheel-REPL-within-NRepl) for project config):

```clojure
;; lein trampoline repl
(use 'project.core)
(start-app [])
(use 'figwheel-sidecar.repl-api)
(start-figwheel!)
```
