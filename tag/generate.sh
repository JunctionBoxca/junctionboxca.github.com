#!/bin/bash -eu


function writeMD() {
  while read tag; do
    echo $tag.md
    cat > $tag.md <<EOT
---
layout: tagpage
title: "Tag: ${tag}"
tag: ${tag}
nocomment:  true
---
EOT
  done
}


cat taglist.txt |  writeMD
