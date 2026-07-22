# builder: build a static Go binary
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN apk add --no-cache build-base git
ENV CGO_ENABLED=0 GOOS=linux GOARCH=amd64
RUN go build -ldflags="-s -w" -o /goapp ./cmd/main.go

RUN go install github.com/golang-migrate/migrate/v4/cmd/migrate@v4.17.0

FROM alpine:3.18
RUN apk add --no-cache ca-certificates
# If migrate binary needs glibc, uncomment:
# RUN apk add --no-cache libc6-compat

COPY --from=builder /goapp /goapp
COPY --from=builder /go/bin/migrate /migrations/migrate

COPY db/migrations /migrations/schemes
COPY static /static
COPY templates /templates

EXPOSE 8080
ENTRYPOINT ["/goapp"]
