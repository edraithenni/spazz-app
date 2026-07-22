# builder: build a static Go binary
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN apk add --no-cache build-base git
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o /goapp ./cmd/main.go

# Download pre-built migrate binary with PostgreSQL support
FROM alpine:3.18 AS migrate-builder
RUN apk add --no-cache curl tar
ADD https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz /tmp/migrate.tar.gz
RUN cd /tmp && tar -xzf migrate.tar.gz && ls -la && mv migrate /tmp/migrate

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
COPY --from=builder /goapp /goapp
COPY --from=migrate-builder /tmp/migrate /migrations/migrate

COPY db/migrations /migrations/schemes
COPY static /static
COPY templates /templates

EXPOSE 8080
ENTRYPOINT ["/goapp"]
