---
title:       Maven to Bazel Preparation
created_at:  2019-06-20 12:00:00 +00:00
layout:      default
published:   true
description:
  Bazel is a fast build tool that works well with a monorepo.
  This post aims to provide some quick guidelines when migrating from
  maven to Bazel.
keywords: bazel, build, java, maven
tags: bazel build java maven
---

Bazel is a multi-language build tool opensourced by Google. It’s core focus is on
“{Correct, Fast}” builds. Bazel is able to achieve this by employing a unique
mechanism to evaluate and act on changes in parallel via a fine-grained dependency
graph.

There are a few things you should be aware of before adopting it:

1. Works best with monorepos.
2. Language support varies.
3. Labourous migrations.

### Works best with monorepos

Bazel can be used with a number of project structures but it is most efficient when
employed in a monorepo. It uses a file named WORKSPACE to indicate the project root
and load dependencies like language plugins. While it is possible to stitch together
traditional repos in a multi-workspace configuration it becomes cumbersome resolving 
and manage third-party dependencies across repos. Multirepos also bring additional
overhead as it abandons the maven concept of manually versioned modules. Instead it
expects repos to be in the master/HEAD position with changes being committed atomically
across the project.

### Language support varies

If you have a Java or CPP project you shouldn’t run into too many issues migrating. They
both have extensive support (if not rough around some edges). Other languages are highly
dependant on community contributions. Kotlin as an example is supported but the official 1.3
rules support is not available yet. While there are often workarounds, unless you’re using a
Google “Blessed” language you’re mileage will vary.

### Laborous Migration

The migration process itself for an existing project can be quite labor intensive.
There’s a number of tools out there that aim to help (bazel-deps, rules_jvm_external, etc)
but none of them are a complete solution. Maven is pretty lax in the specification of dependencies
whereas Bazel is quite strict. Part of its speed is not having to solve version compatibility
during the build. This means if you’re project isn’t using a BOM to manage versions it’s
likely you’ll have multiple versions inflight, something Bazel will reject in the same
dependency graph. As a result introduce a BOM and lift all the dependency
versions to it before migrating to Bazel.

### Conclusions

If you have a doggedly slow build Bazel can definitely pep it up. In my experience I’m
seeing speedups of 2-10x. If you’re willing to put in the effort and have an adaptive
team that enjoys CLI based tooling it’s definitely worth it. If
you’re greenfield start your project with Bazel and avoid a migration later.
