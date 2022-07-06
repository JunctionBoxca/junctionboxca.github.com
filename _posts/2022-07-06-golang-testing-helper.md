---
title:       Golang Testing Helper
created_at:  2022-07-06 12:00:00 +00:00
layout:      default
published:   true
description:
  The receiver (*Testing).Helper was added back in 2017 but is an underrated tool in writing helper functions.

keywords: golang testing
tags: golang testing
---

Go `t.Helper()` makes it easy to report test failures at the call site of the parent function rather than the call site of `t.(Error|Fatal)`. I've used [stretchr/testify](https://github.com/stretchr/testify) in a couple of projects but in general I've not been happy with the extensive use of `interface{}` in the API. It results in a lot of run-time failures that would otherwise be caught with proper types. Another minor quibble is that testify encouraged overwriting the `assert` import namespace with a local `assert` variable in it's docs. With any solution I'd like to address both of those issues.

## An Alternative

With a recent project I decided to write my own assertion library. I settled on the following API:
```
assert.Int(t, actual).Equals(expected)
```

Under the hood it looks as follows:
```
package assert

import "testing"

func Int(t *testing.T, i int) *integer {
	return &integer{i, t}
}

type integer struct {
	a int
	t *testing.T
}

func (i *integer) Equals(b int) {
	if i.a != b {
		i.t.Errorf("want %v, got %v\n", b, i.a)
	}
}
```

While fluent API's aren't considered idiomatic Go, I found them justified in this context. It helps narrow the scope of functions that can be applied to a given type. With IntelliSense it reduces my dependence on looking up docs and keeping focus on the code.

## The gotcha

When I first implemented these functions I found test failures weren't as helpful as  inline conditional block checks. Enter the `Helper()` receiver function. This function rolls the stack to your tests call site rather than the helper call site. So all the trace data points to your helper and not the test. Adding `t.Helper()` solves that in one line:

```
func (i *integer) Equals(b int) {
  i.t.Helper()
	if i.a != b {
		i.t.Errorf("want %v, got %v\n", b, i.a)
	}
}
```