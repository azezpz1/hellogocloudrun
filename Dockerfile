# ---------- Build Stage ----------
FROM golang:1.24.3 AS builder

# Set working directory
WORKDIR /app

# Cache go modules
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the Go app statically for a small final image
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

# ---------- Run Stage ----------
FROM alpine:latest

# Add SSL certs (needed if your app makes outbound HTTPS calls)
RUN apk --no-cache add ca-certificates

# Set working directory
WORKDIR /root/

# Copy built binary from builder
COPY --from=builder /app/server .

# Tell Cloud Run which port to listen on
ENV PORT=8080
EXPOSE 8080

# Run the server
CMD ["./server"]
