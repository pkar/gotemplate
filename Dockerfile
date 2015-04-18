FROM golang:1.4.2-cross

ENV PROJECT_PATH=github.com/pkar/apitool
ENV GOPATH=/go/_vendor:$GOPATH

WORKDIR /go
ADD _vendor /go/_vendor
ADD src/$PROJECT_PATH /go/src/$PROJECT_PATH
