---
title:      Buck on Travis CI
created_at: 2017-10-01 12:00:00 +00:00
layout:     default
published: true
description: Lightspeed is too slow. We'll have to go directly to ludicrous speed!! Buck is a ludicrously fast build tool but is not a widely available default on many of the OSS CI services. Here's how I got it up and running for Java.
keywords: buck, java, ant
---

Special thanks to [Markus Spiske](https://hackernoon.com/getting-started-with-buck-build-on-travis-ci-d1208d363023) for his article which was my starting point for this config.

I'm growing to love [Buck](https://buckbuild.com/). I like the way it encourages you to specify builds as a graph of dependencies. I'd even argue it'll make you a better programmer as it forces you to be explicit with your dependencies. If you create BUCK files at the package level it forces you to give greater consideration to your design as it doesn't permit circular dependencies. All that aside I love it because it's fast! If you want evidence of how fast I'm building an experimental [build tool](https://github.com/nfisher/cljbuck/) for Clojure. Buck runs a fresh build in under 3s from a clean checkout on my machine and an incremental build in under 400ms. I looked at Bazel (Bucks inspiration from Google) as well but found it much slower at 20s for a fresh build.

Ok I'll assume you're convinced to use Buck, that was the hard part... the next bit is getting it to work in CI. For my project I'm using Travis and the final config looks as follows:

```yaml
dist: trusty
language: java

before_install:
  - test -f $HOME/.buck/build/successful-build || sudo apt-get update
  - test -f $HOME/.buck/build/successful-build || sudo apt-get install -y ant
  # Install Buck
  - test -f $HOME/.buck/build/successful-build || git clone --branch v2017.09.04.02 --depth 1 https://github.com/facebook/buck.git $HOME/.buck
  - ls $HOME/.buck
  - cd $HOME/.buck; test -f $HOME/.buck/build/successful-build || ant; cd - # build then jump back to project directory
  - rm -rf $HOME/.buck/.git # don't bother caching the .git folder as it'll bloat the cache
  - $HOME/.buck/bin/buck --version

script:
  - $HOME/.buck/bin/buck test --all

branches:
  except:
    - gh-pages

cache:
  directories:
    - $HOME/.buck/ # this prevents you from having to wait for buck to build every time
    - buck-out/cache # this speeds tings up a bit by retaining the cache across builds
```

With that config the build time will vary depending on whether it's a "clean" build or "incremental". My last [tweak](https://travis-ci.org/nfisher/cljbuck/builds/282049123) to my .travis.yml resulted in a build that was done in 41s not too shabby!

The basic gist of the above config is as follows:

1. Use Trusty and Java language which gives you a 1.8 series JDK.
2. Install Apache Ant because that's how buck is built (they [release](https://github.com/facebook/buck/releases/tag/v2017.09.04.02) deb packages too).
3. Shallow clone the most recent buck tag.
3. Cache the buck build binaries ($HOME/.buck) and the projects buck cache (buck-out/cache) as it'll speed up subsequent builds.
4. If the build gets slow due to the cache download process purge it. The next build will be a little pokey because it needs to build buck again but subsequent builds should be grease lightning.

