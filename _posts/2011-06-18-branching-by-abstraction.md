---
title:      Branching by Abstraction
created_at: 2011-06-18 12:00:00 +00:00
layout: default
keywords: release, branch by abstraction, SCM, CI
description: Branching by Abstraction is like milk and honey for Continuous Delivery. This article discusses some of the issues and motivation for using it.
tags: cd
---

Feature Branches can be highly effective in small teams that commit and remerge often. A small team in my mind is everyone having a seat around a meeting room table. The core benefit of Feature Branches is pretty obvious. It keeps an individual insulated from other developers changes until a merge occurs. SCM tools like GIT have made great strides in helping with those merges.

Overall Feature Branches offer some pretty compelling options. It yields little impact on the mainline while the feature is being developed. If the branches are short-lived with one pair making commits it is unlikely a team will experience noticeable pain with a merge. But what is frequent? A month, a day, a hour, a man hour? And how about small? A method, a class, X lines of code? The problem with Feature Branches are not highlighted until the team is larger and/or more distributed. Fundamentally Feature Branches fail at fulfilling explicit visibility. Feature Branches instead provide implicit visibility. Changes are implied, you can view them if you choose to switch branches, but they otherwise don't affect you. That simple context switch using branches fractures CI. The additional build jobs and context in how release artefacts are generated and tested introduces noise. In turn this complicates inspecting and evaluating the known releasable state of the system.

The primary tenet of [CI](http://martinfowler.com/articles/continuousIntegration.html) is affording developers the ability to work in isolation, while integrating regularly to provide a single source of truth. The truth it yields revolves around the following question; Can the system be released, and what are the systems attributes if released (features, quality, performance, etc)? If Feature X requires a merge to mainline for completion, then it's not releasable and as a result incomplete.

[Branching by Abstraction](http://martinfowler.com/bliki/BranchByAbstraction.html) (Branching by Abstraction), combined with Feature Flags makes visibility explicit as the changes exist in the context of a developers workspace and are not obscured behind SCM branches. CI is maintained as a single source of truth as it continues to provide a clear articulation around a release artefacts' capabilities. Any context switching is at runtime and not during compilation and packaging.

In a temporal sense Branching by Abstraction complicates code, and necessarily introduces duplication, but that's acceptable as it should be refactored after being enabled in production. To reiterate the difference between the temporal state of short-lived Feature Branches and Branching by Abstraction is one of visibility. At it's core Branching by Abstraction is about socialisation and communication of intent. Branching by Abstraction is explicit and directly visible as all changes exist in your workspace. All changes are easily tracked and tested on every checkout. Impact analysis is simplified by simply turning the feature on. Discussions shift from speculation to reality as to how the system will perform when Feature X is turned on. The existence of incomplete features in the code doesn't matter as they should only be integrated with the system at large when they begin to add value. This is where the practise of TDD assists to rapidly test regressions and unexpected changes in behaviour.

Discipline is required to maintain good behaviour for both Feature Branches and Branching by Abstraction. The question to pose is why invest in behaviours that obscure and obfuscate the releasable state of your system?
