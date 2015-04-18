# apitool

This is a go project to make an apitool

### Go information
See [go](docs/go.md)

### Making a release with just Docker and no Go installed
Update the tag at the top of the Makefile or provide it

```bash
$ make release_docker TAG=0.0.2
$ tree bin
bin
├── apitool-v0.0.2.darwin.tar.gz
├── apitool-v0.0.2.linux.tar.gz
├── darwin_amd64
│   └── apitool
└── linux_amd64
    └── apitool

2 directories, 4 files
```

### Making a release with Go installed

```bash
$ make release UNAME=linux; make release UNAME=darwin
$ tree bin
bin
├── apitool-v0.0.1.darwin.tar.gz
├── apitool-v0.0.1.linux.tar.gz
├── darwin_amd64
│   └── apitool
└── linux_amd64
    └── apitool

2 directories, 4 files
```

### Recommended setup after installing Go

```
# clone the repo and setup environment variables
$ git clone ssh://git@github.com/pkar/apitool.git
$ cd apitool
$ eval `make gopath`

$ make build UNAME=linux
```

### Testing

```
$ make test
ok  	github.com/pkar/apitool	0.005s	coverage: 100.0% of statements
```

### See Makefile for available commands

```
make list
```

### Docker information
See [docker](docs/docker.md)
