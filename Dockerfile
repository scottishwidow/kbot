FROM quay.io/projectquay/golang:1.20 as builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

ENV GOOS=$TARGETOS
ENV GOARCH=$TARGETARCH

WORKDIR /go/src/app
COPY . .

RUN make build

FROM alpine:latest

WORKDIR /
COPY --from=builder /go/src/app/kbot .


COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT [ "./kbot" ]
