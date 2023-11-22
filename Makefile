APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=scottishwidow
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)

.PHONY: format lint test get clean linux mac windows arm build

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get

build: format get
	CGO_ENABLED=0 GOOS=${GOOS} GOARCH=${GOARCH} go build -v -o kbot -ldflags "-X=github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}"

linux:
	$(MAKE) build GOOS=linux GOARCH=amd64

mac:
	$(MAKE) build GOOS=darwin GOARCH=amd64

windows:
	$(MAKE) build GOOS=windows GOARCH=amd64

arm:
	$(MAKE) build GOOS=linux GOARCH=arm64

image:
	docker buildx build --platform ${GOOS}/${GOARCH} . -t ${REGISTRY}/${APP}:${VERSION}-${GOARCH}

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${GOARCH}

clean:
	rm -rf kbot 
