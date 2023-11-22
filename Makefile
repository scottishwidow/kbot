APP=${shell basename $(shell git remote get-url origin)}
REGISTRY=scottishwidow
TARGETOS=linux
TARGERARCH=amd64

VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)


format:
	gofmt -s -w ./


lint:
	golint

test:
	go test -v

get:
	go get


build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot -ldflags "-X="github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}

image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-$(TARGERARCH)

push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGERARCH}



clean:
	rm -rf kbot 