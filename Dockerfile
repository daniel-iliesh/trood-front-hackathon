FROM golang:1.24-alpine AS builder

WORKDIR /app

ENV CGO_ENABLED=1

RUN apk update && apk add --no-cache build-base sqlite-dev

COPY go.mod .
COPY go.sum .

RUN go mod download

COPY . .

RUN GOOS=linux go build -a -installsuffix nocgo -ldflags="-s -w" -o /app/main .

FROM alpine:latest

WORKDIR /app

RUN apk update && apk add --no-cache sqlite-libs

COPY --from=builder /app/main .

EXPOSE 8080

ENTRYPOINT ["/app/main"]

