package main

// TODO: documentation

import (
	"bufio"
	"fmt"
	"os"
)

func iscostas(perm []int) bool {
	n := len(perm)
	uniq := make(map[int]bool, n)
	for _, v := range perm {
		uniq[v] = true
	}
	if len(uniq) != n {
		return false
	}
	for k := 1; k < n; k++ {
		var seen uint64
		for i := 0; i < n-k; i++ {
			d := perm[i+k] - perm[i] + n
			bit := uint64(1) << d
			if seen&bit != 0 {
				return false
			}
			seen |= bit
		}
	}
	return true
}

func main() {
	reader := bufio.NewReader(os.Stdin)
	var n int
	fmt.Fscan(reader, &n)
	perm := make([]int, n)
	for i := range perm {
		fmt.Fscan(reader, &perm[i])
	}
	if iscostas(perm) {
		fmt.Println(1)
	} else {
		fmt.Println(0)
	}
}
