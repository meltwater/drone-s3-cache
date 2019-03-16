# build stage
FROM golang:1.11-alpine AS builder
RUN apk add --update make git upx ca-certificates tzdata \
  && update-ca-certificates

ENV BUILD_DIR /build

COPY go.* Makefile $BUILD_DIR/
WORKDIR $BUILD_DIR
RUN make fetch-dependencies

COPY . $BUILD_DIR

# RUN make drone-cache
RUN make build-compressed
RUN cp drone-cache /bin

# final stage
FROM scratch

COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /bin/drone-cache /bin

ENTRYPOINT ["/bin/drone-cache"]
