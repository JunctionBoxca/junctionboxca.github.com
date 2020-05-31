---
title:      Git
created_at: 2011-03-21
layout: default
permalink: /resources/git/
---

## Reference Material

- [Err the Blog](http://cheat.errtheblog.com/s/git/) - good list of commonly used git commands.
- [Git Community Book](http://book.git-scm.com/) - fairly good coverage of common workflows from beginner to advanced.

### Empty server repo

```bash
mkdir -p $REMOTE_REPO_ABSOLUTE_PATH
git --bare init
```


Note: somewhere in your home folder is probably best.

### First push to empty server repo

```bash
git init
git add .
git commit -a -m "Initial push."
git remote add origin ssh://$SERVER_URL/$REMOTE_REPO_ABSOLUTE_PATH
git push origin master
```

### Ranged cherry pick into branch

```
git checkout -b fix644
git rebase -i $COMMIT_ID
```

### Override local changes

```bash
git reset --hard
```


### Initialise a SVN bridge

```bash
git svn init -s $REMOTE_REPO .
git svn fetch
git rebase trunk
git svn dcommit
```


### Remote Tracking

```bash
git branch rspec
git branch --track $BRANCH $REMOTE/$BRANCH
```

### Extract zip of branch

```bash
git archive --format zip --output ${FILE}.zip $BRANCH
```

