---
title:      Vim
created_at: 2012-08-02
layout: default
permalink: /resources/vim/
---

Reformat paragraphs: !par (assumes par package to be installed)

[Vim Script
Programming](http://www.slideshare.net/c9s/vim-script-programming)\
[100 Vim commands every programmer should
know](http://www.catswhocode.com/blog/100-vim-commands-every-programmer-should-know)

### Search Based Navigation

      f{char}     # next {char} on line, position cursor on {char}
      t{char}     # next {char} on line, position cursor immediately before {char}
      F{char}     # prev {char} on line, position cursor on {char}
      T{char}     # prev {char} on line, position cursor immediately after {char}
      /{pattern}  # search forward in current buffer for match
      ?{pattern}  # search backwards in current buffer for match
      ;           # next look ahead
      ,           # previous look ahead
      *           # search for word under the cursor

### Macros

      .           # repeat last change
      q{b}{c}q    # record change (c) macro to buffer (b)
      {n}@{b}     # run the macro in buffer (b), n times
