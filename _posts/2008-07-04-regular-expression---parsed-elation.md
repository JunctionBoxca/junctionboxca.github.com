---
title:      Regular Expression &amp; Parsed Elation
created_at: 2008-07-04 12:00:00 +00:00
layout:     default
tags: regex
---

Here's a little app I wrote during a project to test ActionScript 3's regular expressions.

<object type="application/x-shockwave-flash" data="/images/as3regex.swf" width="760" height="422">
<param name="movie" value="/images/as3regex.swf" />

</object>
Character Classes
-----------------

-   \\w - word character \[A-Za-z0-9\_\]
-   \\W - non-word character \[^\\w\]
-   \\s - space character \[ \\t\\r\\n\]
-   \\S - non-space character \[^\\s\]
-   \\d - digit \[0-9\]
-   \\D - non-digit character \[^\\d\]

Quantifiers
-----------

-   ? - zero or one
-   \\\* - zero or more
-   + - one or more
-   \\{min, max\\} - ranged selection

Avoiding Back-tracking
----------------------

### Negative boundary matching

/"\[^"\]\*"/ - match all characters between double quotes

### Atomic Groups

/"(?&gt;\[^"\]\*)"/ - drops positions after a match is made
