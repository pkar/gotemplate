package apitool

import (
	"flag"
	log "github.com/golang/glog"
)

type APITool struct {
}

func Do() {
	flag.Parse()
	_, err := New()
	if err != nil {

	}
}

func New() (*APITool, error) {
	log.Info("hello")
	r := &APITool{}
	return r, nil
}
