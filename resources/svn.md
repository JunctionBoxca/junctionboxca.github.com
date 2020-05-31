---
title:      SVN
created_at: 2011-03-21
layout: default
permalink: /resources/svn/
---

### Dry run next update

```bash
svn merge --dry-run -r BASE:HEAD .
```

### Add missing files

```bash
alias sva="svn st\|grep \\\^?\|awk '{print \\\$2}'\|xargs svn add"`
```

### Force restore of older revision

```bash
svn merge -r DEST_REV:SRC_REV REPOS_PATH
svn commit
```

Reference Material
------------------

[snipplr.com](http://snipplr.com/view/5745/svn-add-recursively/) -
Inspiration for the adding missing files.
