---
title:      CRDTs For *blank* and Profit
created_at: 2015-10-11 12:00:00 +00:00
layout:     default
published: false
description: 
keywords: crdts
---

CRDT's allow for progress in isolation but ensure eventual consistency. Outside of some business process constraints there's 3 properties you need to pull off a merge;

- commutative - changing order of operands does not affect the result.

- associative - order of application does not affect the result.
- idempotent - duplicate application does not affect the result.

To demonstrate this behaviour I'll use a bank account in a somewhat contrived example. A bank account is generally initialised to £0. A set of transactions might look like this on your monthly bank statement:

| Date       | Desc             |    Amount|   Balance|
|------------|------------------|---------:|---------:|
| 2015-09-01 | Open Account     |     £0.00|     £0.00|
| 2015-09-25 | Pay Day - woohoo |  £1000.00|  £1000.00|
| 2015-09-26 | Rent             |  -£900.00|   £100.00|
| 2015-09-27 | Water Bill       |   -£50.00|    £50.00|

Commutative
-----------

A naive approach to the above bank statement could be represented as:

\`\`\`
0 + 1000 - 900 - 50 = 50
\`\`\`

In the above there are 4 operands and 3 operators. In order for a calculation to be commutative it must have the same result when the operands are changed. If the operands are not strictly associated with their operators it could result in the following:

\`\`\`
1000 + 900 - 50 - 0 = 1850
\`\`\`

To make the above calculation commutative you need to make a simple change:

\`\`\`
(*1000)* (-900) + (-50) + (0) = 50
\`\`\`

The above example over-simplifies the problem. Adding a daily interest charge demonstrates how matters can become complicated due to order of operations.

Associative
-----------

Idempotent
----------
