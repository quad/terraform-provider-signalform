PACKAGE := terraform-provider-signalform
GOPATH  := $(shell pwd -L)
BASE    := $(GOPATH)/src/$(PACKAGE)
PATH    := $(GOPATH)/bin:$(PATH)
export GOPATH
export PATH
# unset GOROOT avoids: "go test error: cannot use matchString as type testing.testDeps in argument to testing.MainStart"
unexport GOROOT
unexport SFX_AUTH_TOKEN

GOOS ?= $(shell go env GOOS)
GOARCH ?= $(shell go env GOARCH)
export GOOS
export GOARCH

.PHONY: all
all: fmt .git/hooks/pre-commit test build itest_trusty itest_xenial

.PHONY: fmt
fmt:
	cd $(BASE) && go fmt ./...

.PHONY: clean
clean:
	rm -rf bin
	rm -rf pkg
	make -C build clean

.PHONY: build
build: test
	mkdir -p $(GOPATH)/bin
	cd $(BASE) && go build -o $(GOPATH)/bin/terraform-provider-signalform

.PHONY: integration
integration:
	make -C test

.PHONY: itest_%
itest_%:
	mkdir -p dist
	make -C build $@

.PHONY: package
package: itest_lucid itest_trusty itest_xenial

.PHONY: binary
binary:
	mkdir -p dist
	make -C build binary

.PHONY: test
test:
	cd $(BASE) && go test -v ./...

.PHONY: changelog
changelog:
	make -C build $@

.git/hooks/pre-commit:
	if [ ! -f .git/hooks/pre-commit ]; then ln -s ../../git-hooks/pre-commit .git/hooks/pre-commit; fi
