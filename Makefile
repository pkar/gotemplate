TAG               = v0.0.1
COMPONENT         = apitool
REPO              = github.com/pkar/$(COMPONENT)
CMD               = $(REPO)/cmd/$(COMPONENT)
IMAGE_NAME        = pkar/$(COMPONENT)
IMAGE_TAG         = latest
IMAGE_SPEC        = $(IMAGE_NAME):$(IMAGE_TAG)
UNAME             := $(shell uname | awk '{print tolower($0)}')
VENDORS = \
	"glog|github.com/golang/glog|github.com:golang/glog.git" \
	"cobra|github.com/spf13/cobra|github.com:spf13/cobra.git"

ifndef GOPATH
$(error GOPATH is not set see https://golang.org/doc/code.html then run eval `make gopath`)
endif

# eval `make gopath`
gopath:
	export GOPATH="$(CURDIR)/_vendor:$(CURDIR)"

# update the Dockerfile with the path to this project
dockerfile:
	@sed -i -e "s/PROJECT_PATH=[^ ]*/PROJECT_PATH=$(REPO)/" Dockerfile
	@if test -e Dockerfile-e; then rm Dockerfile-e; fi

# run once on initial setup
vendor:
	@$(foreach v, $(VENDORS), \
			$(eval X = $(word 1,$(subst |, ,$(v)))) \
			$(eval Y = $(word 2,$(subst |, ,$(v)))) \
			$(eval Z = $(word 3,$(subst |, ,$(v)))) \
			eval "git remote add -f $X git@$Z " || true ; \
	    eval "git subtree add --squash --prefix=_vendor/src/$Y $X master" || true ; \
	)

# update vendored packages
vendor_sync:
	@$(foreach v, $(VENDORS), \
			$(eval X = $(word 1,$(subst |, ,$(v)))) \
			$(eval Y = $(word 2,$(subst |, ,$(v)))) \
			$(eval Z = $(word 3,$(subst |, ,$(v)))) \
			eval "git fetch $X"; \
	  	eval "git subtree pull --squash --prefix=_vendor/src/$Y $X master" || true ; \
	)

# build the current environment binary and put in bin/$UNAME_amd64
# make build UNAME=linux; make build UNAME=darwin
build:
	@mkdir -p bin/$(UNAME)_amd64
	@GOARCH=amd64 GOOS=$(UNAME) go build -o bin/$(UNAME)_amd64/$(COMPONENT)$(TAG) src/$(REPO)/cmd/$(COMPONENT)/main.go

# using docker to build
build_docker:
	@docker build --pull -t $(IMAGE_SPEC) .
	@docker run \
		--rm \
		-v $(CURDIR)/bin/:/go/bin \
		-e GOARCH=amd64 \
		-e GOOS=$(UNAME) \
		$(IMAGE_SPEC) \
	 	go build -o /go/bin/$(UNAME)_amd64/$(COMPONENT)$(TAG) $(REPO)/cmd/$(COMPONENT)

# build an application rpm with docker
build_rpm:
	@$(MAKE) build UNAME=linux
	@sed -i -e "s/VERSION=[^ ]*/VERSION=$(TAG)/" Dockerfile.rpm
	@if test -e Dockerfile.rpm-e; then rm Dockerfile.rpm-e; fi
	@sed -i -e "s/APP=[^ ]*/APP=$(COMPONENT)/" Dockerfile.rpm
	@if test -e Dockerfile.rpm-e; then rm Dockerfile.rpm-e; fi
	@docker build -f Dockerfile.rpm -t $(REPO):rpm .
	docker run --rm -v $(CURDIR)/bin/:/data $(REPO):rpm

tarzip:
	@cd bin/$(UNAME)_amd64 && tar -czvf $(COMPONENT)-$(TAG).$(UNAME).tar.gz $(COMPONENT)-$(TAG)
	@mv bin/$(UNAME)_amd64/$(COMPONENT)-$(TAG).$(UNAME).tar.gz bin/

all:
	@$(MAKE) build UNAME=linux
	@$(MAKE) build UNAME=darwin

all_docker:
	@$(MAKE) build_docker UNAME=linux
	@$(MAKE) build_docker UNAME=darwin
	@-$(MAKE) build_rpm

# install binary to $GOPATH/bin which can be added to $PATH
install:
	go install $(CMD)

run:
	go run $(REPO)/cmd/$(COMPONENT)/main.go

run_interactive:
	docker run \
		--rm \
		-it \
		-v $(CURDIR)/$(REPO):/go/src/$(REPO) \
		$(IMAGE_SPEC) \
		bash

# test with cover
test:
	go test -cover ./...

# test verbose
testv:
	go test -v -cover ./...

# test function
testf:
	# make testf TEST=TestRunCmd
	go test -v -test.run="$(TEST)"

# test race condition
testrace:
	go test -race ./...

# test bench
bench:
	go test ./... -bench=.

vet:
	go vet ./...

# go get -u github.com/golang/lint/golint
lint:
	golint ./...

coverprofile:
	# run tests and create coverage profile
	go test -coverprofile=bin/coverage.out $(REPO)
	# check heatmap
	go tool cover -html=bin/coverage.out

clean:
	@rm -rf bin/*

.PHONY: clean vendor test install release build vet bench gopath dockerfile all all_docker release release_docker
no_targets__:
list:
	@sh -c "$(MAKE) -p no_targets__ | awk -F':' '/^[a-zA-Z0-9][^\$$#\/\\t=]*:([^=]|$$)/ {split(\$$1,A,/ /);for(i in A)print A[i]}' | grep -v '__\$$' | sort"
