---
title:      SVN
created_at: 2011-03-21
layout: default
permalink: /resources/svn/
---

h3. Dry run next update

pre. svn merge –dry-run -r BASE:HEAD .

h3. Add missing files

pre. alias sva="svn st|grep \^?|awk '{print \$2}'|xargs svn add"

h3. Force restore of older revision

pre. svn merge -r DEST_REV:SRC_REV REPOS_PATH
svn commit

h2. Reference Material

"snipplr.com":http://snipplr.com/view/5745/svn-add-recursively/ - Inspiration for the adding missing files.
