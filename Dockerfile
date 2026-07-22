FROM golang:1.21-alpine AS builder

RUN go install -tags 'postgres' github.com/golang-migrate/migrate/v4/cmd/migrate@latest

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN go build -o /goapp ./cmd/main.go

FROM alpine:latest

COPY --from=builder /goapp /goapp
COPY --from=builder /go/bin/migrate /migrations/migrate
COPY db/migrations /migrations/schemes
COPY static /static
COPY templates /templates

EXPOSE 8080
ENTRYPOINT ["/goapp"]
