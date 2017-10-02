---
title:      Security Threat Assessment
created_at: 2015-09-20 12:00:00 +00:00
layout:     default
published: false
description: 
keywords: security
---

At work I've increasingly been involved in security assessments, and developing mitigation strategies for legacy systems. There's a saying I've often used "The safest computer is an unplugged computer". Obviously the statement is tongue-in-cheek. The risk vs reward has to be assessed and evaluated for every situation. The reward is generally a straight forward "it delivers business value" whether that be customer engagement, sales, or fostering partnerships with other companies. The risks are also easily described but are sometimes difficult to quantify in a meaningful way.

Risks
-----

The most common set of risks are:

\# consumer mistrust.
\# competitor advantage.
\# operational costs.
\# litigation.
\# fraud & blackmail.

A recent example of risk realised is Ashley Madison. It is unclear what the final outcome will be but many of the above risks have already manifested themselves as a problem.

Perpetrators
------------

The following list classifies the personas any business or individual should consider when assessing their risk.

|*. Classification |*. Description |
| **Internal:<br/>Unprivileged User** | Employee or contractor:

- may have knowledge of the system.

- does not have a user account in the software.

- has an account for one or more of the hosts associated with the software (e.g. host or database access).

- assumed to have relationships and trust in the organisation.
|
| **Internal:<br/>Privileged User** | Employee or contractor:

- has knowledge of the system.

- has an account in the software and/or

- has an account for one or more of the hosts associated with the software.

- assumed to have relationships and trust in the organisation.
|
| **External:<br/>Privileged User** | Consumer of the system:

- has knowledge of the system.

- has a user account in the software.

- does not have access to the hosts associated with the software.

- may or may not have a relationship and trust in the organisation.
|
| **External:<br/>Unprivileged Targeted** |

- may have knowledge of the system.

- does not have a user account in the software.

- does not have access to the hosts associated with the software.

- likely to seek to build a relationship and trust in the organisation through social engineering.

- likely to make a concentrated effort not to be detected.
|
| **External:<br/>Unprivileged Indiscriminate** |

- unlikely to have knowledge of the system.

- does not have a user account in the software.

- does not have access to the hosts associated with the software.

- more likely to cast a wide net to exploit a number of systems.
- likely to be less concerned about detected but still interested for the sake of keeping access to the system.
|

Methods of Exploitation
-----------------------

I would characterise the primary methods of exploitation as follows:

\# data corruption.
\# privilege escalation.
\# service disruption.
\# social engineering.

### Data Corruption

### Privilege Escalation

### Service Disruption

### Social Engineering

Mitigation Strategies
---------------------
