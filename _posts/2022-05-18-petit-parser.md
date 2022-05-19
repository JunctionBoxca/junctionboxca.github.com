---
title:       Petit Parser for fun
created_at:  2022-05-18 12:00:00 +00:00
layout:      default
published:   true
description:
  Petit parser is a small lightweight parser that I recently gave a spin to write a
  PromQL API.
keywords: java parsing 
tags: java parsing
---

> PetitParser combines ideas from scannnerless parsing, parser combinators, parsing expression grammars (PEG) and packrat parsers to model grammars and parsers as objects that can be reconfigured dynamically.

I first heard of Parser Combinators on an alumni mailing list. It sounded interesting at the time for the way grammars are representetd in code. I didn't have a particular use-case but noted it for the future. I recently had the desire to implement a PromQL API and it seemed the right time to explore parser combinators. I landed on [Petit Parser](https://petitparser.github.io/) and immediately liked the syntax from the examples. The parser was easy to start with and I was suprised that fully functioning applications were possible and not just emission of syntax trees. I wanted to understand the libraries behaviour and started manipulating the [petitparser-json](https://github.com/petitparser/java-petitparser/tree/main/petitparser-json/src/main/java/org/petitparser/grammar/json) example. 

I didn't initially understand the distinction between `JsonGrammarDefinition` and `JsonParserDefinition` nor was I keen of it's inheritance hierarchy. I ran with this design for a bit until I undestood the library. In my final design I settled on using the constructor for grammar definition and a dedicated action method for token transforms instead of an inheritance hierarchy.

My first cut of the PromQL parser emitted raw tokens. Except for Character extraction all other data is emitted as `List<Object>`. Due to Java's type erasure it made composition of combinators a little messy to work with. The main issue I found was interpreting deeply nested structures required a lot of context to be managed.

I settled on writing a parser that emitted strong types instead of nested lists using Java records and primitives rather than token streams which could be nested as you compose combinators. To do this I used the `action()` parser method which calls a Function lambda for each token captured. The action method allows transformation of the token before being emitted.

An example parser that parses a PromQL duration such as `4h5m6s` into an integer is as follows:

```java
    public PromQLGrammarDefinition() {
        def("numberPrimitive", CharacterParser.of('-').optional()
                .seq(CharacterParser.digit().plus()).flatten());

        def("numberToken",
                ref("numberPrimitive").flatten("Expected number").trim());

        def("hour", ref("numberToken").seq(CharacterParser.of('h')));
        def("minute", ref("numberToken").seq(CharacterParser.of('m')));
        def("second", ref("numberToken").seq(CharacterParser.of('s')));

        def("duration", ref(ref("hour").optional())
                .seq(ref("minute").optional())
                .seq(ref("second").optional()));

        def("start", ref("duration").end());

        actions();
    }

    public actions() {
        action("numberToken", (String s) -> Integer.parseInt(s));
        action("hour", (List<Object> d) -> SECONDS_IN_HOUR * (int) d.get(0));
        action("minute", (List<Object> d) -> SECONDS_IN_MINUTE * (int) d.get(0));
        action("second", (List<Object> d) -> (int) d.get(0));
        action("duration", (List<Integer> l) -> {
            int total = 0;
            for (Integer c : l) {
                if (c != null) {
                    total += c;
                }
            }
            return total;
        });
    }
```

When the above parser reads the duration it will emit an integer representing the duration as total seconds. In the example `4h5m6s` it would emit 14,706. Of note ordering is only important between an `action` and it's associated `def`. So in the above `def("hour", ...)` must be defined prior to `action("hour", ...)`). This also allows enforcing strict ordering of hours, minutes, and seconds but can make it slightly tricky handling permutations.

Overall I appreciated the simplicity of the library. The fact that it had no production dependencies was a bonus. The main takeway for me is use types rather than tokens for my own sanity.