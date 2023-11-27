APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=ghcr.io/scottishwidow
# Use a more robust way to define VERSION to avoid trailing dashes
VERSION=$(shell git describe --tags --always --dirty)-$(shell git rev-parse --short HEAD)

.PHONY: format lint test get clean linux mac windows arm build image push

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build -v -o kbot -ldflags "-X main.appVersion=${VERSION}"

linux:
	$(MAKE) build GOOS=linux GOARCH=amd64

mac:
	$(MAKE) build GOOS=darwin GOARCH=amd64

windows:
	$(MAKE) build GOOS=windows GOARCH=amd64

arm:
	$(MAKE) build GOOS=linux GOARCH=arm64

image:
	@echo "Building image for Version: ${VERSION}, Architecture: ${GOARCH}"
	docker buildx build --platform $${GOOS:=linux}/$${GOARCH:=amd64} . -t ${REGISTRY}/${APP}:${VERSION} -f Dockerfile

push:
	@echo "Pushing image for Version: ${VERSION}, Architecture: ${GOARCH}"
	docker push ${REGISTRY}/${APP}:${VERSION}

clean:
	rm -rf kbot
	@if docker images ${REGISTRY}/${APP}:${VERSION} -q | grep -q '.' ; then \
		docker rmi ${REGISTRY}/${APP}:${VERSION}; \
	fi
