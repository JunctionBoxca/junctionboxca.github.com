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

Matrix multiplication is a foundational element in machine learning. It is the basis for propagating an input through a network of weights.

This article gives an overview of the properties of a matrix multiplication and provides an example function in Go.

## The Formula

The formula for a matrix multiplication can be summarised as follows:

```
AB = [n, k=1] Σ Aᵢₖ Bₖⱼ
    = (Aᵢ₁B₁ⱼ) + (Aᵢ₂B₂ⱼ) + ... + (AᵢₖBₖⱼ)
```

A 2d matrix multiplication receives 2 matrices as an input and outputs a new matrix equal to the row height of the first matrix and the column width of the second. The columns of the first matrices and must be equal to the rows of the second.

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
package main

import (
	"errors"
	"fmt"
)

func main() {
	a := New([]int{1, 2,
		3, 4,
		5, 6}, 3, 2)

	b := New([]int{7, 8, 9,
		10, 11, 12}, 2, 3)
	prod := make([]int, a.Rows()*b.Cols())
	Product(a, b, prod)
	fmt.Printf("%v\n", prod)
}

func Product[T Numeric](a, b *Dense[T], sum []T) error {
	if a.Cols() != b.Rows() {
		return errors.New("unaligned matrices")
	}

	p := b.Cols()

	for i := 0; i < a.Rows(); i++ {
		for k, c := range a.Row(i) {
			for j, r := range b.Row(k) {
				sum[i*p+j] += c * r
			}
		}
	}
	return nil
}

func New[T Numeric](cells []T, rows, cols int) *Dense[T] {
	return &Dense[T]{rows: rows, cols: cols, cells: cells}
}

type Numeric interface {
	~int | ~float32 | ~float64
}

type Dense[T Numeric] struct {
	rows  int
	cols  int
	cells []T
}

func (d *Dense[T]) Rows() int {
	return d.rows
}

func (d *Dense[T]) Cols() int {
	return d.cols
}

func (d *Dense[T]) Row(i int) []T {
	start := i * d.Cols()
	return d.cells[start : start+d.Cols()]
}
```
