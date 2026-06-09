package main

import "flag"

// newFlagSet returns a FlagSet that exits on parse errors with a usage hint.
func newFlagSet(name string) *flag.FlagSet {
	return flag.NewFlagSet(name, flag.ExitOnError)
}
