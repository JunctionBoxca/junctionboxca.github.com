---
title:      Calendar Tables in PostgreSQL
created_at: 2013-04-09 12:00:00 +00:00
layout:     default
published: true
description: Hadoop and MapReduce has made data warehousing all the rage but, don't give up on the trusty old RDBMS. Learn how to populate a calendar table using only PostgreSQL built-in features.
keywords: postgresql, data-warehousing
tags: sql
---

I've just started a new job with [Maxymiser](http://www.maxymiser.com/) that I'm pretty excited about. With enough active and passive collection of data to accumulate Terabytes in a short period of time we have a treasure trove of data that can be analysed. One of the first tasks I've been assigned is improving our ability to explore the data more readily so I'm evaluating a few tools;

-   [Logstash](http://www.logstash.net/) - opensource goodness using solr.
-   [Splunk](http://www.splunk.com/) - tried and true workhorse for log analysis.
-   [HBase/Hadoop](http://hbase.apache.org) - all the Map/Reduce love you can muster on commodity hardware.
-   [PostgreSQL](http://www.postgresql.org) - an oldie but, a goodie!

Our primary concerns are security, performance, maintainability and extensibility. As I mentioned we're looking at some reasonably sized data warehousing which warrants some testing and hammock time.

A personal goal of mine is to establish an apdex (Application Performance Index) rating for all of the tiers in our infrastructure. An [apdex rating](http://apdex.org/) is a simple performance metric using a scale of 0.0 to 1.0 that avoids the skewing which can occur when using averages on response time (think big outliers e.g. 30s response for 1 connection out of hundreds). To quote [wikipedia](http://en.wikipedia.org/wiki/Apdex);

> Apdex (Application Performance Index) is an open standard developed by an alliance of companies. It defines a standard method for reporting and comparing the performance of software applications in computing. Its purpose is to convert measurements into insights about user satisfaction, by specifying a uniform way to analyze and report on the degree to which measured performance meets user expectations.

To achieve this measurement I'll aggregate all of our logs and use the response time to calculate the apdex rating (0 - satisfying, 1 - tolerating and 2 - frustrated). The logs will be aggregated into a star schema with the following dimensions;

-   calendar - denormalised date columns.
-   request/response - uri, response code, etc.
-   user-agent - raw string, os, family.
-   infrastructure element - server, tier, location.
-   request facts table - apdex rating, time spent to fulfill request, etc.

Now that I'm almost past the fold in your browser lets get into detail on creating a calendar table. The main use case for a calendar table is to trade-off space (denormalised data) for an improvement in time per query. It can be useful when asking questions like; "How much traffic did we have during the 4th quarter for the last 2 years?" By including apdex calculations you can ask "How did our infrastructure cope during that time?".

As alluded to earlier a calendar table is heavily denormalised around date/time attributes. The fields I feel are most useful in our current use case include;

    day id - date primary key 
    year - year in UTC
    month - month in UTC
    day - day in UTC
    quarter - business quarter
    day of week - a numeric identity representing Mon-Sun
    day of year - a numeric identity for the absolute day within the year (instead of the current month)
    week of year - pretty self explanatory

Translating them into a table DDL looks a little like this before indexes are applied;

    CREATE TABLE calendar (
      day_id DATE NOT NULL PRIMARY KEY,
      year SMALLINT NOT NULL, -- 2012 to 2038
      month SMALLINT NOT NULL, -- 1 to 12
      day SMALLINT NOT NULL, -- 1 to 31
      quarter SMALLINT NOT NULL, -- 1 to 4
      day_of_week SMALLINT NOT NULL, -- 0 () to 6 ()
      day_of_year SMALLINT NOT NULL, -- 1 to 366
      week_of_year SMALLINT NOT NULL, -- 1 to 53
      CONSTRAINT con_month CHECK (month >= 1 AND month <= 31),
      CONSTRAINT con_day_of_year CHECK (day_of_year >= 1 AND day_of_year <= 366), -- 366 allows for leap years
      CONSTRAINT con_week_of_year CHECK (week_of_year >= 1 AND week_of_year <= 53)
    );

Nothing special there. The next bit is where the fun comes in, generating the table data. Now, I'll be honest I considered popping out to Python or Clojure to generate the data but, I decided to spend a little time getting reacquainted with PostgreSQL. After reading through the docs and getting assistance on IRC from Myon this is what we're using;

    INSERT INTO calendar (day_id, year, month, day, quarter, day_of_week, day_of_year, week_of_year)
    (SELECT ts, 
      EXTRACT(YEAR FROM ts),
      EXTRACT(MONTH FROM ts),
      EXTRACT(DAY FROM ts),
      EXTRACT(QUARTER FROM ts),
      EXTRACT(DOW FROM ts),
      EXTRACT(DOY FROM ts),
      EXTRACT(WEEK FROM ts)
      FROM generate_series('2012-01-01'::timestamp, '2038-01-01', '1day'::interval) AS t(ts));

As far as I'm concerned that's a pretty compact and concise way to generate the calendar records without being difficult to understand. As expected the query was done in a snap and now I've got the date dimension loaded for dates up to 2038-01-01. A small sample of data from the table looks as follows;

| date\_id   | year | month | day | quarter | day\_of\_week | day\_of\_year | week\_of\_year |
|------------|------|-------|-----|---------|---------------|---------------|----------------|
| 2012-01-13 | 2012 | 1     | 13  | 1       | 5             | 13            | 2              |
| 2012-01-14 | 2012 | 1     | 14  | 1       | 6             | 14            | 2              |
| 2012-01-15 | 2012 | 1     | 15  | 1       | 0             | 15            | 2              |
| 2012-01-16 | 2012 | 1     | 16  | 1       | 1             | 16            | 3              |
| 2012-01-17 | 2012 | 1     | 17  | 1       | 2             | 17            | 3              |

I've started loading some of our w3c formatted log files using copy but, haven't had an opportunity to do any in-depth analysis. One thing I investigated before creating the DDL was URI length. The [RFC](http://www.faqs.org/rfcs/rfc2616.html) recommends limiting URI's to 255 bytes for (old) proxies. Well in a sample of 600k requests I found requests in excess of 4k long! They're likely an exploit might be an opportunity to do active request filtering using machine learning. Anyway that's it for today, time for bed!

Updated: 2013-04-10 - Provided further clarifications for Apdex rating and Calendar table.
