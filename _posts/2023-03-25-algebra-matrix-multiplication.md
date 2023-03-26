---
title:       Matrix Multiplication
created_at:  2023-03-25 12:00:00 +00:00
layout:      default
published:   true
description:
  Matrix multiplication is part of a series of calculations that lead into the fundamentals of machine learning. This article gives an overview of the properties of a matrix multiplication and provides an example function in Go.

keywords: machinelearning algebra golang
tags: machinelearning algebra golang
---

The formula for a matrix multiplication can be summarised as follows:

```
AB = n, k=1 Σ Aᵢₖ Bₖⱼ
    = (Aᵢ₁B₁ⱼ) + (Aᵢ₂B₂ⱼ) +  # algorithmic 
```

Matrix multiplication serves a number of immediate use cases:

1. 

#### Example

```
A = [[1, 2],
     [3, 4],
     [5, 6]]

B = [[7, 8, 9],
     [10, 11, 12]]

AB = [[1x7 + 2x10, 1x8 + 2x11, 1x9 + 2x12],
      [3x7 + 4x10, 3x8 + 4x11, 3x9 + 4x12],
      [5x7 + 6x10, 5x8 + 6x11, 5x9 + 6x12]]

   = [[27, 30, 33],
      [61, 68, 75],
      [95, 106, 117]]
```

## Code Sample

The following is a code sample using Go generics.

```golang
func Product[T Numeric](a, b [][]T) (*Dense[T], error) {
	if len(a[0]) != len(b) {
		return nil, errors.New("unaligned matrices")
	}

	if len(a) == 0 || len(a[0]) == 0 || len(b) == 0 || len(b[0]) == 0 {
		return nil, errors.New("empty matrices")
	}

	m := len(a)
	p := len(b[0])

	var sum = make([]T, m*p)
	for i, row := range a {
		for k, c := range row {
			for j, r := range b[k] {
				index := i*p + j
				sum[index] += c * r
			}
		}
	}

	return &Dense[T]{m: m, p: p, cells: sum}, nil
}

type Numeric interface {
	~int | ~float32 | ~float64
}

type Dense[T Numeric] struct {
	m     int
	p     int
	cells []T
}
```

