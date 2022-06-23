---
title:       Git Stacked Commits
created_at:  2022-06-22 12:00:00 +00:00
layout:      default
published:   true
description:
  Ruminations on Git stacked commits.

keywords: git workflow
tags: git workflow
---

In the ideal we'd be adopting XP practises and [Trunk Based Development](https://trunkbaseddevelopment.com/) however most orgs are doubling down on PR's and Git branch based workflows as standard practise. Unfortunately this often means accumulating ever larger, long lived PR's. The longer a PR hangs around the more painful merge conflicts can be. Cisco apparently did an internal review on PR's and found 250 LoC to be the optimal upper limit for a PR. This creates an interesting issue. PR's if done well take time to review. For 250 LoC it was cited you should expect an engineer to dedicate around 1 hour on average. Even with a team ruthlessly prioritising PR's that's a bit of an obstacle to a dev getting into a flow state.

## Trunk Based Development

So what alternatives are there? As mentioned previously Trunk Based Development handles this quite nicely but has some assumptions around discipline and experience.

1. everyone makes many small commits a day.
2. feature flags and abstraction branches are used consistently to guard WIP code from being exposed.
3. builds and tests are fixed or commits are reverted as quickly as they happen.

Not all teams are keen to use this process and in the absence of pairing it can cause issues in org that requires all code is reviewed prior to being integrated into the main branch.

## Stacked Commits

Another alternative that seems common in MANGA is stacked commits. Stacked commits are a process of making many small branches+PR's that maintain a hierarchical dependency. In essence you try to capture one logical piece of functionality per branch/PR (e.g. migration, DTO, API, UI). Stacking requires that branches are merged from the bottom up and upstream branches are rebased to main as downstream branches are merged.

## Prior Art

There's a number of tools that support Stacked Commits to varying degrees but a few examples include:

* [Gerrit](https://www.gerritcodereview.com/) - not compatible with GitHub.
* [Graphite](https://graphite.dev/) - SaaS so might not work for everyone.
* [gh-stack](https://github.com/timothyandrew/gh-stack/) - limited in capabilities.

I recently listened to some of the Graphite founders on ChangeLog. One of the core tenants for their product is a parachute should always be available to use standard git workflows. This allows a dev to fallback to git should they encounter a state the Graphite engineers didn't consider.

Graphite looks great but is a SaaS product. In a large org that could require substantial effort to receive authorisation of use than I feel like addressing.

## Requirements

What would a MVP workflow look like? What attributes would I want to improve on existing systems? What concerns would need to be addressed?

#### Must

- Allow fixes pushed to a PR anywhere in the stack.
- Easy identification of a stacks branches/PRs.
- Not depend on a 3rd party SaaS product.

#### Should

- Minimise the use of out of band state.
- Provide ability to squash commits.
- Handle rebasing.
- Create PRs for branches.
- Allow others to branch a stack (I'm not convinced this is a good idea).

#### Must Not

- Prevent fallbacks to git CLI tools.

## Potential Workflow

Some systems use [git notes](https://git-scm.com/docs/git-notes) as a means of tracking relationships. This might be useful but what if stacks branches were organised similar to database migrations where each layer in the stack used a numbered prefix and the stack itself was a slash prefix? This provides the benefit of grouping and ordering the stacks with CLI tools and Github UI alike. One potential restriction is that it wouldn't allow divergent branches in a stack like some other tools do but I suspect that's a good way to create a ball of mud. What would a potential workflow look like?

Standard Stacking

```
git stack init issue123/create_migration # creates branch issue123/001_create_migration.
git add .
git commit # commits the staged changes.
git stack branch create_api # squashes previous branch and creates branch issue123/002_create_api
git add .
git commit # standard git commit.
git stack squash # squash and rebase branches.
git stack push # push with lease.
```

Fix a branch based off of PR feedback

```
git stack status # list all stacks branches
git stack checkout 001 # checkout stack branch issue123/001_create_migration.
git add .
git commit
git stack squash
git stack push # push with lease.
```

Rebase merged branches

```
git stack rebase # rebase dependent branches to merged main branches.
git stack push # push with lease.
```

This seems like an adequate start for a naive implementation. I suspect I'll need to address a number of edge cases in the process as I've not used the workflow previously.
