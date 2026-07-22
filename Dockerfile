FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o /goapp ./cmd/main.go

FROM alpine:latest AS migrate-builder

ADD https://github.com/golang-migrate/migrate/releases/download/v4.17.0/migrate.linux-amd64.tar.gz /tmp/migrate.tar.gz
RUN mkdir -p /migrations && tar -xzf /tmp/migrate.tar.gz -C /migrations && mv /migrations/migrate.linux-amd64 /migrations/migrate && chmod +x /migrations/migrate

FROM alpine:latest

COPY --from=builder /goapp /goapp
COPY --from=migrate-builder /migrations/migrate /migrations/migrate
COPY db/migrations /migrations/schemes
COPY static /static
COPY templates /templates

EXPOSE 8080
ENTRYPOINT ["/goapp"]
