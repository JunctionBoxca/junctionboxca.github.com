---
title:       Dot Product
created_at:  2022-07-06 12:00:00 +00:00
layout:      default
published:   true
description:
  Dot product is part of a series of calculations that lead into the fundamentals of machine learning. This article gives an overview of the properties of a dot product calculation and provides an example function in Go.

keywords: machinelearning algebra golang
tags: machinelearning algebra golang
---

The formula for a dot product can be summarised as follows:

```
A⋅B = ║A║║B║ cos θ
    = (A₁B₁) + (A₂B₂) # algorithmic
```

A dot product serves 2 primary uses:

1. Expresses relationship of direction between 2 vectors:
  * 0 is perpendicular.
  * +ve is an acute angle.
  * -ve is an obtuse angle.
2. Yields simplified projections.

#### Perpendicular Vectors

Perpendicular vectors will result in a 0 value.

```
A = [8, 0] 
B = [0, 9]

A⋅B = (8x0) + (0x9)
    = 0

A = [9, 1]
B = [-1, 9]

A⋅B = (9x-1) + (1x9)
    = 0
```

#### Acute Angles (<90°)

Will always yield a positive number.

```
# 1st quadrant
A = [8, 2]
B = [2, 9]

A⋅B = (8x2) + (2x9)
    = 34

# 2nd quadrant
A = [-8, 2]
B = [-2, 9]

A⋅B = (-8x-2) + (2x9)
    = 34

# 2nd and 3rd quadrant

A = [-8, 2]
B = [-8, -2]

A⋅B = (-8x-8) + (2x-2)
    = 62
```

#### Obtuse Angles (>90°)

Will always yield a negative number.

```
A = [-10, 1]
B = [1, 9]

A⋅B = (-10x2) + (1x9)
    = -11
```

#### nD vectors

```
A = [2, 3, 4]
B = [3, 4, 5]

A⋅B = (2x3) + (3x4) + (4x5)
    = 38
```

## Simple Code Sample

The following is a simple code sample using Go generics.

```golang
type Numeric interface {
	~int | ~float32 | ~float64
}

func Dot[T Numeric](a, b []T) (T, error) {
	if len(a) != len(b) {
		return 0, errors.New("unaligned vectors")
	}

	if len(a) == 0 {
		return 0, errors.New("empty vectors")
	}

	var sum T = 0
	for i := range a {
		sum += a[i] * b[i]
	}

	return sum, nil
}
```


### Glossary

<dl>

<dt>cartesian coordinates</dt>
<dd>A real number coordinate system that uses N pairs of real numbers to specify a points location in the dimensional space relative to the planes intersection.</dd>

<dt>euclidean space</dt>
<dd>Ordinary two-, three-, or n-dimensional space represented by positive integers.</dd>

<dt>matrix</dt>
<dd>An array of vectors.</dd>

<dt>scalar</dt>
<dd>A quantity only possessing magnitude.</dd>

<dt>tensor</dt>
<dd>An entity with components that change in a defined way between different coordinate systems.</dd>

<dt>vector</dt>
<dd>A quantity possessing both magnitude and direction.</dd>

</dl>
