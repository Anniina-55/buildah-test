FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY . .

RUN go build -o server main.go

FROM alpine:3.20

WORKDIR /app
COPY --from=builder /app/server /server
COPY www /app/www

EXPOSE 8085

CMD ["/server"]
