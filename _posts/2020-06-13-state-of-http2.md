---
title:       State of HTTP2
created_at:  2020-06-13 12:00:00 +00:00
layout:      default
published:   true
description:
  The HTTP2 spec was published as an Internet Draft May 30th, 2015. Five years later and the capabilities seem to vary wildly across libraries. With HTTP3 fast approaching I was curious the current state of play for some of the bigger libraries I encounter regularly.
keywords: http2 java go
tags: http2 java go
---

The [HTTP2 spec](https://http2.github.io/http2-spec/) was published as an Internet Draft May 30th, 2015. Five years later and the capabilities seem to vary wildly across libraries. With HTTP3 fast approaching I was curious the current state of play for some of the bigger libraries I encounter regularly.

This document aims to identify what capabilities exist for the libraries.

The implementation details of HTTP2 start at section 3 in the spec. I will aim to document compatibility of the following libraries over the coming weeks. Starting with server compatibility and then client compatibility. Server compatibilty should be relatively easy using [h2spec](https://github.com/summerwind/h2spec).

## Server Libraries

1. Go stdlib.
1. Project Reactor.
1. Java 11 stdlib.
1. Netty.

## Client Libraries

1. Go stdlib.
1. Netty.
1. OK HTTP.
1. Project Reactor.
1. Java 11 stdlib.

| no.   | Title                                |
| ===== | ==================================== |
| 3.    | Starting HTTP/2 |
| 3.1   | HTTP/2 Version Identification |
| 3.2   | Starting HTTP/2 for "http" URIs |
| 3.2.1 | HTTP2-Settings Header Field |
| 3.3   | Starting HTTP/2 for "https" URIs |
| 3.4   | Starting HTTP/2 with Prior Knowledge |
| 3.5   | HTTP/2 Connection Preface |
| 4.1   | Frame Format |
| 4.2   | Frame Size |
| 4.3   | Header Compression and Decompression |
| 5.1   | Stream States |
| 5.1.1 | Stream Identifiers |
| 5.1.2 | Stream Concurrency |
| 5.2.2 | Appropriate Use of Flow Control |
| 5.3.1 | Stream Dependencies |
| 5.3.2 | Dependency Weighting |
| 5.3.3 | Reprioritization |
| 5.3.4 | Prioritization State Management |
| 5.3.5 | Default Priorities |
| 5.4   | Error Handling |
| 5.4.1 | Connection Error Handling |
| 5.4.2 | Stream Error Handling |
| 5.4.3 | Connection Termination |
| 5.5   | Extending HTTP/2 |
| 6.    | Frame Definitions |
| 6.1   | DATA |
| 6.2   | HEADERS |
| 6.3   | PRIORITY |
| 6.4   | RST_STREAM |
| 6.5   | SETTINGS |
| 6.5.1 | SETTINGS Format |
| 6.5.2 | Defined SETTINGS Parameters |
| 6.5.3 | Settings Synchronization |
| 6.6   | PUSH_PROMISE |
| 6.7   | PING |
| 6.8   | GOAWAY |
| 6.9   | WINDOW_UPDATE |
| 6.9.1 | The Flow-Control Window |
| 6.9.2 | Initial Flow-Control Window Size |
| 6.9.3 | Reducing the Stream Window Size |
| 6.10  | CONTINUATION |
| 7.    | Error Codes |
| 8.    | HTTP Message Exchanges |
| 8.1   | HTTP Request/Response Exchange |
| 8.1.1 | Upgrading from HTTP/2 |
| 8.1.2 | HTTP Header Fields |
| 8.1.3 | Examples |
| 8.1.4 | Request Reliability Mechanisms in HTTP/2 |
| 8.2   | Server Push |
| 8.2.1 | Push Requests |
| 8.2.2 | Push Responses |
| 8.3   | The CONNECT Method |
| 9.    | Additional HTTP Requirements/Considerations |
| 9.1   | Connection Management |
| 9.1.1 | Connection Reuse |
| 9.1.2 | The 421 (Misdirected Request) Status Code |
| 9.2   | Use of TLS Features |
| 9.2.1 | TLS 1.2 Features |
| 9.2.2 | TLS 1.2 Cipher Suites |