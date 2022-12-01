FROM --platform=$BUILDPLATFORM golang:1.19.3-alpine as build

RUN apk add --update-cache tzdata && rm -rf /var/cache/apk/*

WORKDIR /build

COPY go.mod .
COPY go.sum .

RUN go mod download
RUN go mod verify

ARG GIT_VERSION=develop

COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags "-s -w -X main.version=$(GIT_VERSION)" -o /chirpstack-packet-multiplexer cmd/chirpstack-packet-multiplexer/main.go

# copy forwarder and certs to base image.
FROM scratch 

LABEL authors="ThingsIX Foundation"

COPY --from=build /chirpstack-packet-multiplexer  .

ENTRYPOINT ["./chirpstack-packet-multiplexer"]