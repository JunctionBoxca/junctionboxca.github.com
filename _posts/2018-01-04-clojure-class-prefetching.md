---
title:       Clojure Speedup - Class Prefetching
created_at:  2018-01-04 12:00:00 +00:00
layout:      default
published:   true
description: This is my second article in a series on Clojure start-up timings.
             The focus for this article is Class Prefetching.
keywords: clojure, java, jvm
---

In my previous article on
[Clojure start-up timings](/2017/12/26/clojure-startup-walkthrough.html)
I outlined four optimisations. The focus for this article will be optimising
start-up by employing what I'll call class prefetching. The solution outlined
can be applied more broadly to JVM based command-line tools. This article
contains the following sections; 

 1. Problem description.
 2. Target solution.
 3. Naive solution.
 4. Results.
 5. Conclusion.

Problem Description
-------------------

Class loading from JAR files in Java imposes latency that varies depending on
the size, complexity, and dependencies of the class. This loading process first
searches the classpath for the class, reads it from the classpath file as a
stream, then translates the Java byte-code to platform specific code, which is
then stored in the code cache. The process can impose as much as single to
double digit millisecond latency the first time a class is seen. In a long
running service this is rarely a concern as most classes will be loaded into the
JVM's
[code cache](https://docs.oracle.com/javase/8/embedded/develop-apps-platforms/codecache.htm#A1101612)
with very few requests/executions. Where it is a concern many sites will employ
[warm-up requests](https://devcenter.heroku.com/articles/warming-up-a-java-process)
with realistic data to both load the classes and minimise the impact of the JIT
swapping in code optimisations (incidentally JIT optimisation is a reason to
keep method size a reasonable size). For command-line tools on the otherhand
start-up performance is a more valuable attribute, particularly where a command
is frequently executed by hand or machine. The main issue that contributes to
the additional latency is the interleaving of "work" and class loading as
illustrated below;

![work and class loading interleaved](https://junctionbox.ca/images/cljperf/prefetch-interleaved.png)

The implication in the above diagram is that the classes are only loaded when
and where they're needed which means the latency is experienced at that point in
time. This in turn serialises class load latency with work. To further compound
the situation the default JVM Classloader loads classes in serial to avoid
loading issues (the joy of ciruclar dependencies!).


Target Solution
---------------

The optimal solution is to load the classes into the code cache before the work
is executed to minimise the latency at the callsite. The most effective way to
do this is to execute class loading in parallel to class execution otherwise
it shuffles the above diagram with little to no impact on start-up latency.

![parallel class loading](https://junctionbox.ca/images/cljperf/prefetch-parallel.png)

The trick is to ensure the classes are available when required and compute time
isn't unnecessarily stolen from "work". As a result the order in which classes
are loaded is important so the working threads have the class in the code cache
when needed. Failing to order the classes correctly risks increasing start-up
latency. I don't recall the genesis for this solution but it might've been in
conversation with
[Dan Bodart](http://dan.bodar.com/2012/02/28/crazy-fast-build-times-or-when-10-seconds-starts-to-make-you-nervous/).

This solution is similar to processor pipelining and HTTP/2's
[multiplexing](https://cascadingmedia.com/insites/2015/03/http-2.html).

Naive Solution
--------------

The naive solution is to load all of the classes as early in the main process as
possible. This is achieved by creating the following thread class;

```
package clojure;

public class PrefetchThread extends Thread {
    private volatile int length = 0;

    public void run() {
        final Class[] prefetch = {
          clojure.lang.Seqable.class,
          // etc...
        };

        synchronized (this) {
            length = prefetch.length;
        }
    }

    public volatile int getLength() {
      return length;
    }
}
```

Which requires the following addition as the first lines in `clojure.main/main`;

```
    PrefetchThread pt = new PrefetchThread();
    pt.start();
```

As I mentioned previously class ordering is important so I simply used the JRE's
`-verbose:class` flag which outputs the classes in order as they're loaded by
the class loader. Using a similar execution to my previous post looks as follows;

```
$ java -verbose:class -cp clojure.jar:`cat maven-classpath` \
  clojure.main -e '(prn "hello")'
[Opened /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.lang.Object from /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.io.Serializable from /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.lang.Comparable from /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/rt.jar]
[Loaded java.lang.CharSequence from /Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home/jre/lib/rt.jar]

... etc ...

```

Then it's a matter of transforming each line to an array entry (e.g.
java.lang.Object.class). Note that `prefetch` variable has a method level scope
this is to prevent serialising the load of the classes when the PrefetchThread
class is visible.

There are a few issues with this approach;

 1. Private classes need to be pruned.
 2. There's a circular dependency on the Clojure class being available at
    compile time.
 3. The benefit doesn't scale to improve latency as more Clojure classes are
    added.

Results
-------

 To measure this and minimise bias I executed each Clojure
jar (prefetch and standard) 202 times and extracted the results as measured by
time. The executions were split into batches of 101 executions each. The first
execution is a "warm-up", the subsequent 100 exections are sorted from low to
high which provides a poormans percentile ranking.

The data looks as follows;

<style>
svg {
display: block;
margin: 0px;
padding: 0px;
height: 100%;
width: 100%;
}
</style>

<div id="chart" style="height: 350px;">
<svg></svg>
</div>

<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.17/d3.min.js" integrity="sha256-dsOXGNHAo/syFnazt+KTBsCQeRmlcW1XKL0bCK4Baec=" crossorigin="anonymous"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.8.6/nv.d3.min.js" integrity="sha256-Eg29ohiE9Hzc/t5whG/QK/B8MGmrO4wkF6WGuSsx0VU=" crossorigin="anonymous"></script>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.8.6/nv.d3.min.css" integrity="sha256-bmrwGjHOoD7azP+ZpGcOOitUNUGNRjwzjK1bZeTK6fI=" crossorigin="anonymous" />

<script>
"use strict";

var std = d3.csv('/media/std.log.csv', addData('standard'));
var std2 = d3.csv('/media/std2.log.csv', addData('standard 2'));
var pf =  d3.csv('/media/pf.log.csv', addData('prefetch'));
var pf2 =  d3.csv('/media/pf2.log.csv', addData('prefetch 2'));
var data = [null, null, null, null];
var chart = null;
var chartData = null;
var indexes = {'standard':0, 'standard 2':1, 'prefetch': 2, 'prefetch 2': 3};

function addData(label) {
  return function(error, rows) {
    if (error != null) {
      console.log(error);
      return;
    }
    var i = indexes[label];


    data[i] = {
        label: label,
        values: {
          Q1: rows[24].t * 1000,
          Q2: rows[49].t * 1000,
          Q3: rows[74].t * 1000,
          whisker_low: rows[0].t * 1000,
          whisker_high: rows[99].t * 1000,
          outliers: []
        },
      };

    chartData.datum(data).transition().duration(500).call(chart);
    nv.utils.windowResize(chart.update);
  };
}

nv.addGraph(function() {
      chart = nv.models.boxPlotChart()
        .x(function(d) { return d.label })
        .staggerLabels(true)
        .maxBoxWidth(75) // prevent boxes from being incredibly wide
        .yDomain([820, 980]);

      chartData = d3.select('#chart svg')
                    .datum(data);

      chartData.call(chart);

      nv.utils.windowResize(chart.update);

      return chart;
    });
</script>


Conclusion
----------

So after all of this fanfare what impact does it have on Clojure start-up? Well
it's not earth shattering but the median speed-up is around 40ms (4%). This
could be further improved by combining the existing `run()` method with a queue.
This would allow for more dynamic behaviour in the prefetch thread. The 40ms
isn't huge but when combined with conditional loading of the server that's a 9%
improvement in start-up latency. Without dynamic fetching the improvement
doesn't scale as the users code base grows.

There's a core tradeoff in this optimisation which is that the speculative
execution and loading of classes where not immediately required could steal
processor time where other work could be done. However in the context of
Clojure's current implementation and with it's extensive use of static fields
that issue already exists.

