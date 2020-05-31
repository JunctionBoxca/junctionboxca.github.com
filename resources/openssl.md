---
title: OpenSSL
created_at: 2013-08-21
layout: default
permalink: /resources/openssl/
---

### Encrypt a file

`openssl aes-256-cbc -a -salt -in $INFILE -out $OUTFILE`

### Decrypt a file

`openssl aes-256-cbc -d -a -in $INFILE -out $OUTFILE`
