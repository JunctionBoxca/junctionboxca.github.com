---
title:       Recreational GraphQL use
created_at:  2018-03-01 12:00:00 +00:00
layout:      default
published:   true
description:
  GraphQLs hype seems to have hit a fever pitch in my tech circle.
  Like any new technology I figured it’s utility was somewhere between nil and
  unicorn pixie dust that will “revolutionise” the way I code.  The only way to
  find out was to roll up my sleeves and start coding.
keywords: python, graphql
---

GraphQLs hype seems to have hit a fever pitch in my tech circle. Like any new
technology I figured it’s utility was somewhere between nil and unicorn pixie
dust that will “revolutionise” the way I code.  The only way to find out was to
roll up my sleeves and start coding.

Peeling back the hype machine and reading the [docs](https://facebook.github.io/graphql/October2016/)
for the first time I’d advise you to hold judgement. There’s some obvious
performance implications that will cry out to you if you’ve ever had to improve
the performance of n+1 queries. I decided to suppress my concern and wrote the
most innovative API this side of Dagobah. Yet another Star Wars API.

The first version was using [go-neelance](https://github.com/graph-gophers/graphql-go).
It seems the preferred choice in Go based on my subjective interpretation of the
docs and a few posts I happened upon around the web. For this version I kept it
simple; an in-memory map, six entity types, and a handful of queries and
mutations. Once I wired graphiql into my API I experienced a small hit of
dopamine as I was able to query data in a range of structures and forms without
having to write additional server side code. Having satiated my curiosity I
made some notes and put my toy back on the shelf.

Fast forward a couple of months and I found myself interviewing and accepting a
job offer with [ShipHero](http://shiphero.com/careers/) using GraphQL and
Python. I decided it might be worth my while to brush up on Python so I [wired](https://github.com/nfisher/graphenespike)
together an API using [graphene](http://graphene-python.org/) and Cassandra to
force a more “realistic” implementation.

Overall both frameworks were a pleasant experience to hack with but there were
a few nagging concerns which I didn’t fully bottom out in either spike.

Namely how it would scale in terms of codebase, load, and latency.

My first concern is with the protocol itself;

- n+1 queries.
- pagination.

In respect to code I felt there were a handful of things that concerned me
specific to the framework implementations;

- code duplication.
- caching behaviour.
- observability.

Some of these issues I tried to resolve. Others I merely rested in a hammock
and considered possible solutions.

## performance: n+1 and then some.

If you follow the framework tutorials to the letter they’ll result in n+1
queries for each entity layer in the graph. The Star Wars data set I used is
tiny relative to what any production system is likely to contain. Even with
that small amount of data it wasn’t hard to drive queries that were exceeding
500ms on my local machine (16GB Mac Pro). Not horrible considering the
flexibility it provides but not ideal if you layer on edge latency of a few
hundred ms for delivery to the user. There were two performance improvements I
made to overcome this;

1. Using batch queries, typically with an IN clause.
2. Using dataloader which optimises the queries through a combination of
localised caching and improved batching.

## duplication: under my umbrella-ella-ella

This is a problem specific to both frameworks. For me it feels there’s a
misalignment of the domain logic in that the resolver is associated with the
field rather than the type. I admit this might simply be a matter of working
with a toy and the fact the Star Wars data-set is inherently circular. In any
case I think the resolvers would be better placed on the entity type rather
than associated with the field. To clarify take this simplified example;

```
class Character(ObjectType):
    films = List(Film)
    def resolve_films(self, info):
        return get_films(self.films)
  
class Starships(ObjectType):
    films = List(Film)
    def resolve_films(self, info):
        return get_films(self.films)
```

Even in refactoring out the `get_films` the number of resolvers required felt
excessive in my spike. This maybe a matter of greater flexibility in a larger
codebase so it’s possibly an uninformed criticism. The open question still
remains is this the best place for the resolver function to reside? It feels
like it would be better placed with the entity type rather than the field but
if the query or post-processing is unique per resolver then it makes sense to
leave it as is. Yes I could DRY it up using an Interface or AbstractType but it
would still feel misaligned.

Naively I think you could facilitate the required functionality with two
methods introduced onto the Film class. One to find the films by ID (`get`) and
another by additional attributes such as a secondary field value (`get_by`) or
keyword args. In terms of implementation I think something like this might
result in lower duplication across the codebase and a more concise expression
of intent.

```
class Character(ObjectType):
    films = List(Film, order=(“release_date”,”ASC”))

class Film(ObjectType):
    def get(self, ids, **kwargs):
      return get_films(ids, kwargs)
```

This is armchair coding so there’s likely a number of conditions I’ve neglected
and would welcome feedback.

## performance: should I cache or should I go now

By default the grapene dataloader caches look-ups in memory. I have yet to dig
into the code for dataloaders eviction strategy but if you’re not careful this
could be a source of all sorts of problems associated with stale data and
memory leaks. The simplest way to address this is to generate the loaders per
request in the root query and mutation resolvers. Thread local storage,
assuming you’re not using an event based server, makes them easily accessible
and in my opinion is a good balance between minimising requests and keeping
data fresh. I would prefer a better way to provide additional context like
dataloaders, connection pools, and tracers to resolvers but I have not found
something that I’m completely happy with yet.

In my spike I implemented the loaders as a global variable which left a little
sick in my mouth if I’m honest. I’d rather inject them via a common interface
or constructor but it doesn’t seem that’s easily facilitated via the standard
graphene API for flask.

## visibility: I can see clearly now the stampede is gone

The final issue I experienced was visibility of what is going on under the
hood. I ended up instrumenting the API with Jager and OpenTracing but it would
be nice if this were box standard (across the Python ecosystem) and you could
simply wire in a reference to the tracer via the view factory method. There is
the Apollo trace standard but it only captures when requested where distributed
tracing can measure end-to-end latency across services and allow for later
review/inspection of production issues.

## Conclusions

Overall I like GraphQL as an alternative to REST and RPC. I think I would need
a little more time before I felt comfortable deploying it as a public facing
API. The n+1 queries seem like they can pose a real risk of DoS. I think it
will still be some time before security best practises are commonly available
and understood by [OWASP](https://www.owasp.org/index.php/Main_Page) and
library maintainers alike.

