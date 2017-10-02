---
title:      R Simple Data Analysis
created_at: 2013-06-27 12:00:00 +00:00
layout:     default
published: true
description: R is a great tool for statistical analysis. It particularly comes in handy when you want to load and normalise data as illustrated here.
keywords: R, statistics
---

While composing the results of our performance tests recently, I started investigating R to programmatically generate graphs. Excel was proving to be tedious, error-prone, and unstable. It was particularly frustrating to work with the JMeter response tables which have about 500,000 rows each. What immediately amazed me about R was how well it handled CSV files and modifying data sets. As an example using the following CSV data;

    ts,t
    1000,40
    2000,47
    3000,53
    4000,35

Loading into R and converting time in milliseconds to seconds was as simple as;

    response_times = read.csv("perf.csv")
    response_times$ts = response_times$ts / 1000

Note I didn't have to do an apply, loop, etc to divide all of the data in the set by 1000 (I tried the [apply](http://stat.ethz.ch/R-manual/R-devel/library/base/html/apply.html) function initially). While I wouldn't say R is ideal as a general purpose language it's incredibly well suited for anything involving statistical analysis. If you're looking at building graphs ggplot2 provides an easy way to generate graphs.
