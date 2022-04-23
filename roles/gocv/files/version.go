// What it does:
//
// 	This program outputs the current OpenCV library version to the console.
//
// How to run:
//
// 		go run ./cmd/version/main.go
//
//  *** Remove example build contraint ***

package main

import (
	"fmt"

	"runtime"

	"gocv.io/x/gocv"
)

func main() {
	fmt.Printf("gocv version: %s\n", gocv.Version())
	fmt.Printf("opencv lib version: %s\n", gocv.OpenCVVersion())
	fmt.Printf("go version: %s\n", runtime.Version())
}
