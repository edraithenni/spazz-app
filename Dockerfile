# Instead of building migrate yourself, copy from the official image
FROM migrate/migrate:v4.17.0 AS migrate-tool

FROM golang:1.21-alpine AS builder
# ... rest of build ...

FROM alpine:3.18
RUN apk add --no-cache ca-certificates

COPY --from=builder /goapp /goapp
COPY --from=migrate-tool /migrate /migrations/migrate

COPY db/migrations /migrations/schemes
COPY static /static
COPY templates /templates

EXPOSE 8080
ENTRYPOINT ["/goapp"]
