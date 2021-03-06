---
title:      Hidden Cost of the Internet
created_at: 2012-08-18 12:00:00 +00:00
layout:     default
keywords:   servers, internet, power, energy
description: Servers are power hungry, this article explores just how hungry those 33m servers that run the internet are.
---

It's estimated there are 33m servers in the world \[[1](#gigaom)\]. So let's do some quick napkin math (there're massive holes here that I'll detail later). Assuming an average power consumption of 450 watts (W)/server \[[2](#opencompute)\] this will amount to 14.85 gigawatts of power consumption per hour. To put that in perspective, the Fukushima power plant had a maximum functional output of 4,696 megawatts (MW) \[[3](#fukushima)\]. To power all of those servers it would take a little over 3 Fukushima power plants running at peak capacity. Keep in mind 4,696 MW can service approximately 2,141,376 UK homes (assumming 4 kWh annual consumption \[[4](#ukpower)\] ). The mathematical shortcut is to say 1 servers' annual power consumption is roughly equal to 1 homes' average annual consumption. Below is a table of calculations in case I made a mistake somewhere.

| Desc                                              | Calculation                     |
|---------------------------------------------------|---------------------------------|
| Number of internet servers                        | 33,000,000                      |
| Power per server (kW)                             | 0.45                            |
| Total internet server power (kW)                  | 33,000,000 \* 0.45 = 14,850,000 |
| Fukushima Daiichi installed capacity (kW)         | 4,696,000                       |
| Fukushimas Daiichis required                      | 14,850,000 / 4,696,000 = 3.16   |
| Annual UK household consumption consumption (kWh) | 4000                            |
| Avg power per UK household (kW)                   | 4000/365/24 = 0.456             |
| Homes/Fukushima                                   | 4,696,000 / 0.456 = 10,298,246  |

Now I said this was back of the napkin math, which makes all of these calculations a gross over-simplification. Nuclear reactors do not run at peak capicity, nor do servers consume 0.45kWh all the time. Both are generally lower in their respective power output (~3.4 MWh) and consumption (wildly variable). However, given there's a whole whack of other things hiding behind the scenes such as network gear, UPS's, line conditioners, duplicate rails of power, disk arrays, power factor (A/C's best friend), the list goes on... basically, I feel confident but not certain that the estimate is on the low end.

### What's my point?

Abstraction is a powerful tool and the internet is about as abstract as it gets, but we should occassionally look under the hood and try to understand what's happening. The best thing to do is to know your off-peak hours and consider powering off or suspending your servers during that time. It'll help the environment and test that the init scripts are working as expected. :)

#### References

\#(\#gigaom) - [The ultimate geek road trip: North Carolina's mega data centre cluster](http://gigaom.com/cleantech/a-geeks-road-trip-north-carolinas-data-center-cluster/), Gigaom
\#(\#opencompute) - [Open Compute Powersupply](http://opencompute.org/projects/power-supply/)
\#(\#fukushima) - [Fukushima Nuclear Reactor](http://en.wikipedia.org/wiki/Fukushima_I_Nuclear_Power_Plant), Wikipedia
\#(\#ukpower) - [Household Electricity Survey Final report](http://randd.defra.gov.uk/Document.aspx?Document=10043_R66141HouseholdElectricitySurveyFinalReportissue4.pdf), Department for Environment Food and Rural Affairs (UK)

Updated: 2013-01-09 - thanks to [Justin Hellings](http://justin.hellings.me.uk) for his recommended changes.
