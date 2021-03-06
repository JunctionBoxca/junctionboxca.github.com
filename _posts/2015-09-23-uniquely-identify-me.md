---
title:      Uniquely Identify Me
created_at: 2015-09-23 12:00:00 +00:00
layout:     default
published: true
description: I recently revisited the landscape for autonomous and uncoordinated identity generation. I came across a couple of criticisms on the use of UUID's and I wanted to explore and validate those criticisms.
keywords: uuids, latency, performance
tags: sql golang
---

{{site.base_url}}
I recently revisited the landscape for autonomous and uncoordinated identity generation. During some research I landed on an article by Richard Clayton titled [Do you really need a UUID/GUID?](https://rclayton.silvrback.com/do-you-really-need-a-uuid-guid). His assertions regarding performance seem to be based on the results from [GUID/UUID vs Integer Insert Performance](http://kccoder.com/mysql/uuid-vs-int-insert-performance/). While I agree with his theme that trade-offs must be addressed rationally, I found myself asking questions around the nuance of his perspective.

This article is my exploration of each point raised and includes results from my own performance testing. It is not intended as criticism towards either author.

To review here are the six items Richard Clayton laid out:

- [To most DB's, UUIDs are just 36 character strings](#uuids-in-36-bytes)
- [UUIDs degrade database performance](#uuids-degrade-performance)
- Are UUIDs the right data structure for the task?
- [Application writes records to a single database](#single-writer)
- [There is a natural key for your record](#natural-record-keys)
- [Presentation to a user](#asthetics--usability)

An additional point I'm adding is:

- [Architectural Influence](#architecture)

UUID's in &lt;36 Bytes
----------------------

For a person UUID's are generally represented as 36 character strings but a computer will happily [represent a UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier#Definition) as 16 bytes. You could use various combinations of integers but you're treading into the territory of [Lilliput and Blefusco](https://en.wikipedia.org/wiki/Lilliput_and_Blefuscu#History_and_politics). In binary representation there is a 4x increase in memory size over 32-bit ints versus ~8x for the string repesentation. UUID's aren't free with binary representation but it is half the size in binary form.
In terms of design decisions in a small system this should rarely be a factor to consider for performance or storage reasons but definitely one in terms of complexity. For a larger system you want the available range that a UUID or equivalent provide.

UUID's Degrade Performance
--------------------------

KCCoder demonstrated using CHAR (36) will cause severe degradation of performance the greater the number of insertions. I was curious what the story looks like with binary representation. This article covers serial insertions, in an upcoming article I will test with concurrency to force contention. All of the tests were written in golang and I plan to use [goroutines](http://programmers.stackexchange.com/questions/222642/are-go-langs-goroutine-pools-just-green-threads) for concurrent insertions. My aim for creating two test scenarios is the first should isolate latency related to DB housekeeping (e.g. index rebalancing). The second test aims to demonstrate how contention impacts that housekeeping (if at all).

Each test will insert 10 million records. I explicitly separated UUID creation from the timings related to DB insertion to avoid conflating insertion performance with UUID generation. Generally any cost associated with UUID generation will be spread across your application tier and therefore should have minimal impact in a live environment.

I've made the test and analysis code available under my GitHub account in the [uids repository](https://github.com/nfisher/uids).

### Serial Insertion Results

Cutting to the chase the timing to complete results for 10m insertions usinga binary UUID were within 25% of integer insertion as can be seen below:

|         | Total Time | Increase |
|---------|------------|----------|
| INTEGER | 1:10:47    | -        |
| UUID    | 1:28:23    | 25.7%    |

Looking at KCCoders graph I would estimate it took slightly more than 10h to insert 10m UUID's in human readable form. By representing the UUID in binary format it would appear the insertion time can be reduced by an order of magnitude. An overview of the overal latency and throughput is below:

|        |                  |                      |
|--------|------------------|----------------------|
|        | **Latency (ms)** | **Throughput (RPS)** |
|        | UUID             | ID                   |
| Median | 21               | 1                    |
| 95PCTL | 27               | 18                   |
| 99PCTL | 53               | 21                   |
| Max    | 665              | 305                  |

As you can see ID insertion provided a more consistent behaviour with little change between the median and max throughput. However UUID insertion improved significantly from KCCoders test with a machine friendly representation. A more detailed overview of the effects on throughput and latency is demonstrated in the graphs below. The graphs were generated by grouping requests into 1s buckets. From each bucket the count represents throughput and the max latency is the latency measurement.

![Graph of serial insertion of 10m Integers](/images/serial-id-10m.png "Graph of serial insertion of 10m Integers")

In the Integer graph above you can see that insertion throughput is fairly linear over time. There are occassions where throughput clearly drops but, it's relatively stable throughout the whole test.

![Graph of serial insertion of 10m UUIDs](/images/serial-uuid-10m.png "Graph of serial insertion of 10m UUIDs")

In the UUID graph above you can see a number of latency spikes (tall verticle blue lines). The general downward slope of throughput indicates it is degrading over time. Also of note the level of variation between adjacent points that results in a thicker red line indicates the stability of performance between batches of inserts isn't as tight as integers. In a perfect system you'd want to see a thin horizontal line for both latency and RPS.

From the results it is clear neither provide perfectly uniform performance but Id insertions definitely provide a more desirable behaviour in this test-case. The UUID test agrees with KCCoders tests in that UUID performance does degrade over time just not at the extreme that he found in his tests.

Single Writer
-------------

If you have a stable application base and a reasonable understanding of your market totally agree. No need to invest in the additional complexity of a UUID. However, if you're a start-up with realistic growth potential (e.g. consumer facing rather than b2b) you'll probably want to take the hit on a UUID as it pushes ID generation out to your application nodes allowing for routing to storage based on UUID.

Natural Record Keys
-------------------

There might be situations where a combination of entries can represent the key. Excluding SSN the other attributes are prone to change. People change phone-numbers, hosts change IP's, and time marches on. An independent ID will generally provide you with a mechanism to link all of these changes. The hashing strategy implies immutability a nice property to have but, not always flexible for a DB style datastore where change is ideally a low effort process.

Asthetics & Usability
---------------------

This point I agree with but I feel it's somewhat subjective. For developers and computers end-points with number identifiers make sense for users they may not. If making the URL's user friendly is a priority consider providing users with a labelling facility. With labels users can gather detail directly from the URL. Using numbers maybe more compact than UUID's but exposing either integers or UUID's is a functional short-cut. It exposes implementation detail about the application that may or may not be helpful to the user.

Starting with Richard's example:
`/user/345123/task/12`

If this were an admin view then I would introduce a unique username:
`/users/nfisher/tasks/12`

If it were a users view then the scoping feels unnecessary:
`/tasks/12`

Taking it to the ultimate conclusion:
`/tasks/finish_writing_article_on_ids`

Numbers are useful where the identity exposed to the user is in the response body:
`/customers/markel/invoices/1234`

Architectural Influence
-----------------------

As I've alluded to previously complexity is a beast to be constrained where possible. By using a UUID instead of a primitive you can simultaneously add and remove complexity. Within code using a primitive is a great simplification. From an architectural perspective however a primitive could be an Achilles heel as generation needs to be centrally co-ordinated. Whether or not central co-ordination will be a limiting factor requires a realisitic assessment of your market and your growth potential within that market.

To demonstrate the complexity I'm referencing here are a few examples in Golang:

**Equality**

```go
// int
id1 == id2
// uuid
bytes.Compare(id1, id2) == 0
```

**Formatting**

```go
// int
fmt.Sprintf("%v", id)
// uuid
fmt.Sprintf("%x-%x-%x-%x-%x", uuid[0:3], uuid[4:5], uuid[6:7], uuid[8:9], uuid[10:])
```

**New**

```go
// Auto-increment in DB using int32
insertId := `INSERT INTO contacts
(firstname, lastname, website) VALUES (?, ?, ?)`
statement, _ := db.Prepare(insertId)
statement.Exec("Nathan", "Fisher", "junctionbox.ca")
// UUID generation
uuid := make([]byte, 16)
rand.Read(uuid)
uuid[6] = (uuid[6] & 0x0f) | 0x40
uuid[8] = (uuid[8] & 0x3f) | 0x80
insertUuid := `INSERT INTO contacts
(uuid, firstname, lastname, website) VALUES (?, ?, ?, ?)`
statement, _ := db.Prepare(insertUuid)
statement.Exec(uuid, "Nathan", "Fisher", "junctionbox.ca")
```

Some operational attributes:

|             | Int32                  | UUID                        |
|-------------|------------------------|-----------------------------|
| Generation  | database or consensus  | optimistic local generation |
| Uniqueness  | guaranteed             | probabalistic               |
| Chronology  | implicit               | N/A                         |
| Collisions  | N/A                    | regenerate and retry        |
| Max Records | 2^32                   | 2^128                       |
| Sharding    | modulo or range blocks | modulo or range blocks      |

Let me know your thoughts and experiences with UUID's in the comments!
