package apitool

import (
	"testing"
)

func TestDo(t *testing.T) {
	Do()
}

func TestNew(t *testing.T) {
	_, err := New()
	if err != nil {
		t.Fatal(err)
	}
}
