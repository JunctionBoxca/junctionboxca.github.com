---
title:      Puppet Guidelines
created_at: 2013-01-26 12:00:00 +00:00
layout:     default
description: Puppet is a configuration management tool that induces a love/hate relationship in many delivery teams. This guideline provides some practises that I've found beneficial for maintaining manifests.
keywords: configuration management, puppet
---

### To be or noop to be.

Noop will help identify change before it happens, great for the commitment-phobes on your team. If you aren’t 100% confident of the changes puppet will make, then it’s a good idea to give it a dry-run. It can save your bacon in a pinch, especially from those fat fingers that add changes manually!

```shell
puppet apply --verbose \
        --noop \
        --summarize \
        --show_diff
```

### No stage left here, avoid the stage

Stages in puppet reduce re-usability (over valued in many dev shops IMHO). More importantly they make it difficult to restructure and reorganise puppet manifests as resource dependencies are transitively defined via the stage rather than explicitly defined by their direct dependents.

### This isn’t Goldman Sachs, avoid excessive Execs

Execs are prone to odd behaviour and failures. Usually they aren’t necessary (e.g. starting services) sometimes they are (apt-get update). They obscure the function of the command, require individual review, and can sometimes be tricky to prevent from executing on subsequent puppet runs.

### Steve Jobs? No. Then don’t micromanage file lines

You either know what you want in a configuration file or you shouldn’t be touching it one line at a time. Puppet runs in order according to dependencies only. As a result line-wise management may result in files that are potentially different between nodes, and can cause subtly different behaviour. While a minor point it’s also not very efficient and bloats the manifest code. Don’t micromanage a files’ lines, use a template or static file instead.

### Avoid Conditionals in Templates

Templates with extensive conditionals are difficult to evaluate if you have shared code prefer a partial instead. Well named templates should document intended usage.

### Heavy modules? Put them on a module diet by avoiding binaries

Binaries placed in puppet modules bloat the repository, increase load on the puppet master (checksums), and generally result in a high kitten mortality rate. Place them in a well known repository (e.g. web server, s3, file share, etc).

### Library roulette, avoid installed/present/latest

Explicitly define the revision you expect to be on the machine it will help ensure every node is configured with same package and reduce errors due to minor changes in supporting libraries. You wouldn't want two different versions of your db server running in production would you?

**TIP**: On Ubuntu you can list available versions with the following command (substitute ntp with the desired package);

`sudo apt-cache madison ntp`

### Children are expensive, prefer composition over inheritance

Composition provides you with greater flexibility. It enables the addition of default parameters that maintain an old interface but, permits the expansion of a class to the needs of a new use case. Deep inheritance hierarchies usually require duplication and often result in expensive/risky refactorings to modify.

#### Inheritance (sad panda)

    node default {
      package { ‘ntp’: 
        ensure => $::ntp_version,
      }
    }

    node web inherits default {
      package { ‘nginx’:
        ensure => $::nginx_version,
      }
    }

    node oldntp {
      package { ‘ntp’: 
        ensure => ‘1.2.3’,
      }
    }

    node backend inherits oldntp {
      package { ‘nginx’:
        ensure => $::nginx_version,
      }
    }

**Note**: Puppet won't let you redefine an existing resource in the graph, even if they are similar in definition so yes this is a bad example.

#### Composition (preferred)

    class default($ntp=$::ntp_version) {
      package { ‘ntp’: 
        ensure => $ntp,
      }
    }

    node web {
      include default
    }

    node backend {
      class { ‘default’:
        ntp_version => ‘1.2.3’,
      }
    }

### Conclusion

I don't consider this a comprehensive list for using puppet as a configuration management tool but, it's a good start of things to watch out for.
