#!/bin/bash -eu

function buildTagList() {
  find _posts -name \*.md \
    | xargs -n1 grep 'tags:' \
    | cut -d' ' -f 2- \
    | xargs -n1 \
    | sort \
    | uniq > taglist.txt
}

function writeMD() {
  while read tag; do
    
    cat > tag/$tag.md <<EOT
---
layout: tagpage
title: "Tag: ${tag}"
tag: ${tag}
nocomment:  true
---
EOT
  echo "Wrote tag/$tag.md"
  done
}

buildTagList

cat taglist.txt |  writeMD
