



format:
	gofmt -s -w ./

build:
	go build -v -o kbot -ldflags "-X"github.com/scottishwidow/kbot/cmd.appVersion=${VERSION}