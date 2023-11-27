ifeq '$(findstring ;,$(PATH))' ';'
    TARGEROS := windows
	TARGETARCH := amd64

else
    TARGEROS := $(shell uname | tr '[:upper:]' '[:lower:]' 2> /dev/null || echo Unknown)
    TARGEROS := $(patsubst CYGWIN%,Cygwin,$(TARGEROS))
    TARGEROS := $(patsubst MSYS%,MSYS,$(TARGEROS))
    TARGEROS := $(patsubst MINGW%,MSYS,$(TARGEROS))
	TARGETARCH := $(shell dpkg --print-architecture 2>/dev/null || amd64)

endif

APP=$(shell basename $(shell git remote get-url origin))
REGESTRY=ghcr.io/scottishwidow
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
	
format:
	gofmt -s -w ./

get:
	go get

lint:
	golint

test:
	go test -v

build: format get
	@printf "$GDetected OS/ARCH: $R$(TARGEROS)/$(TARGETARCH)$D\n"
	CGO_ENABLED=0 GOOS=$(TARGEROS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X="github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}

linux: format get
	@printf "$GTarget OS/ARCH: $Rlinux/$(TARGETARCH)$D\n"
	CGO_ENABLED=0 GOOS=linux GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X="github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=linux -t ${REGESTRY}/${APP}:${VERSION}-linux-$(TARGETARCH) .

windows: format get
	@printf "$GTarget OS/ARCH: $Rwindows/$(TARGETARCH)$D\n"
	CGO_ENABLED=0 GOOS=windows GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X="github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=windows -t ${REGESTRY}/${APP}:${VERSION}-windows-$(TARGETARCH) .

darwin:format get
	@printf "$GTarget OS/ARCH: $Rdarwin/$(TARGETARCH)$D\n"
	CGO_ENABLED=0 GOOS=darwin GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X="github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=darwin -t ${REGESTRY}/${APP}:${VERSION}-darwin-$(TARGETARCH) .

arm: format get
	@printf "$GTarget OS/ARCH: $R$(TARGEROS)/arm$D\n"
	CGO_ENABLED=0 GOOS=$(TARGEROS) GOARCH=arm go build -v -o kbot -ldflags "-X="github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}
	docker build --build-arg name=arm -t ${REGESTRY}/${APP}:${VERSION}-$(TARGEROS)-arm .

image: build
	docker build . -t ${REGESTRY}/${APP}:${VERSION}-$(TARGETARCH)

push:
	docker push ${REGESTRY}/${APP}:${VERSION}-$(TARGETARCH)


clean:
	@rm -rf kbot; \
	IMG1=$$(docker images -q | head -n 1); \
	if [ -n "$${IMG1}" ]; then  docker rmi -f $${IMG1}; else printf "$RImage not found$D\n"; fi