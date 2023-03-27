---
title:       Perceptron
created_at:  2023-03-26 12:00:00 +00:00
layout:      default
published:   true
description:
  Matrix multiplication is part of a series of calculations that lead into the fundamentals of machine learning. This article gives an overview of the properties of a matrix multiplication and provides an example function in Go.

keywords: machinelearning golang
tags: machinelearning golang
---

The function for a perceptron can be summarised as follows:

```
f(x) = { 1 if w⋅x + b > 0
         0 otherwise
```

## Code Sample

The following is a code sample using Go generics.

```golang
package main

import (
	"encoding/csv"
	"errors"
	"fmt"
	"log"
	"math"
	"math/rand"
	"os"
	"strconv"
)

func main() {
	log.SetFlags(0)

	input := &Data[float64]{}
	err := LoadIris(input, true)
	if err != nil {
		log.Fatalln(err)
	}
	input.Split(0.70)
	fmt.Println(input.TargetName)

	_, features := input.Shape()
	p := New[float64](features)
	err = Fit(p, 10000, 0.0001, input, step)
	if err != nil {
		log.Fatalln("fit", err)
	}

	result, err := input.Test(func(X []float64) (float64, error) {
		return Predict(p, X, false, step)
	})
	if err != nil {
		log.Println(err)
	}

	log.Printf("precision=%0.2f%%\n", result)
}

type stepFn[T Numeric] func(T, error) (T, error)

// Fit trains a perceptron (p) on the data set (d) over a number of iterations (iters). It uses the step function (step)
// to align the data to the labels. The learning rate (r) influences how much change there is to the weights for each
// correction.
func Fit[T Numeric](p *Perceptron[T], iters int, r T, d *Data[T], fn stepFn[T]) error {
	for n := 0; n < iters; n++ {
		err := d.Train(func(X []T, target T) error {
			Yjt, err := fn(Dot(p.Weights, X))
			if err != nil {
				return err
			}

			if Yjt == target {
				return nil
			}

			diff := Yjt - target
			for j, w := range p.Weights {
				p.Weights[j] = w - r*diff*X[j]
			}
			return nil
		})
		if err != nil {
			return err
		}
	}
	return nil
}

func step[T Numeric](x T, err error) (float64, error) {
	if err != nil {
		return 0, err
	}
	s := math.Round(float64(x))
	if s > 0 {
		return s, nil
	}
	return 0, nil
}

func Predict[T Numeric](p *Perceptron[T], x []T, addBiasCol bool, fn stepFn[T]) (T, error) {
	if addBiasCol {
		x = append(x, 1)
	}
	return fn(Dot(p.Weights, x))
}

func New[T Numeric](features int) *Perceptron[T] {
	weights := make([]T, features)
	return &Perceptron[T]{
		Weights: weights,
	}
}

type Perceptron[T Numeric] struct {
	Weights []T
}

type Data[T Numeric] struct {
	Values     [][]T
	Target     []T
	TargetName map[string]T
	Headers    []string
	features   int
	train      []int
	test       []int
}

func (d *Data[T]) Shape() (int, int) {
	return len(d.Values), d.features
}

func (d *Data[T]) Split(pct float64) {
	order := make([]int, len(d.Values))
	for i := 0; i < len(order); i++ {
		order[i] = i
	}
	rand.Shuffle(len(order), func(i, j int) {
		order[i], order[j] = order[j], order[i]
	})
	trainSz := int(pct * float64(len(d.Values)))
	d.train = order[:trainSz]
	d.test = order[trainSz:]
}

func (d *Data[T]) Train(fn func(X []T, target T) error) error {
	for _, i := range d.train {
		err := fn(d.Values[i], d.Target[i])
		if err != nil {
			return err
		}
	}
	return nil
}

func (d *Data[T]) Test(fn func(X []T) (T, error)) (float64, error) {
	var correct int
	for _, i := range d.test {
		p, err := fn(d.Values[i])
		if err != nil {
			return 0, err
		}
		if p == d.Target[i] {
			correct++
		}
	}
	return float64(correct) / float64(len(d.test)) * 100.0, nil
}

func LoadIris[T Numeric](d *Data[T], addBiasColumn bool) error {
	r, err := os.Open("iris.csv")
	if err != nil {
		return err
	}

	f := csv.NewReader(r)
	records, err := f.ReadAll()
	if err != nil {
		return err
	}

	d.Headers = records[0][:len(records[0])-1]
	d.TargetName = map[string]T{}

	records = records[1:] // trim header row
	var a []T
	for _, row := range records {
		name := row[len(row)-1]
		v, ok := d.TargetName[name]
		if !ok {
			v = T(len(d.TargetName)) + 1
			d.TargetName[name] = v
		}
		d.Target = append(d.Target, v)
		a = []T{}
		for _, s := range row[:len(row)-1] {
			f, err := strconv.ParseFloat(s, 64)
			if err != nil {
				return err
			}
			a = append(a, T(f))
		}
		if addBiasColumn {
			a = append(a, 1)
		}
		d.Values = append(d.Values, a)
	}
	d.features = len(a)

	return nil
}

func Dot[T Numeric](a, b []T) (T, error) {
	if len(a) != len(b) {
		return 0, fmt.Errorf("unaligned vectors a=%d, b=%d", len(a), len(b))
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

type Numeric interface {
	~int | ~float32 | ~float64
}

```
