# Go Blockchain Utilities

High-performance Ethereum blockchain utilities written in Go using go-ethereum (Geth).

## Features

- 💰 Balance queries
- 📦 Block number retrieval
- 🌐 Chain ID detection
- 📄 Contract detection
- 🔐 Key pair generation
- ✅ Signature verification
- ⚡ Fast performance with native Go

## Installation

```bash
# Initialize module
go mod download

# Build
go build -o blockchain-utils main.go
```

## Usage

### Check Balance

```bash
go run main.go balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

Output:
```
💰 Balance: 1.234567 ETH
```

### Get Latest Block

```bash
go run main.go block
```

Output:
```
📦 Latest Block: 18500000
```

### Get Chain ID

```bash
go run main.go chain
```

Output:
```
🌐 Chain ID: 1 (Ethereum Mainnet)
```

### Check if Contract

```bash
go run main.go contract 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

Output:
```
📄 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb is a Smart Contract
```

### Generate Key Pair

```bash
go run main.go generate
```

Output:
```
🔐 New Account Generated
   Address:     0x1234...
   Private Key: 0xabcd...

⚠️  WARNING: Store the private key securely!
```

## API Usage

```go
package main

import (
    "fmt"
    "log"
)

func main() {
    // Connect to Ethereum
    utils, err := NewBlockchainUtils("https://eth.llamarpc.com")
    if err != nil {
        log.Fatal(err)
    }

    // Get balance
    balance, err := utils.GetBalance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Balance: %s Wei\n", balance.String())

    // Get block number
    blockNum, err := utils.GetBlockNumber()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Block: %d\n", blockNum)

    // Get chain ID
    chainID, err := utils.GetChainID()
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Chain ID: %s\n", chainID.String())

    // Check if contract
    isContract, err := utils.IsContract("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb")
    if err != nil {
        log.Fatal(err)
    }
    fmt.Printf("Is Contract: %t\n", isContract)
}
```

## Key Generation

Generate ECDSA key pairs for Ethereum:

```go
privateKey, address, err := GenerateKeyPair()
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Address: %s\n", address)
```

## Signature Verification

Verify ECDSA signatures:

```go
message := []byte("Hello, Ethereum!")
signature := []byte{...} // 65 bytes
publicKeyHex := "0x04..."

valid, err := VerifySignature(message, signature, publicKeyHex)
if err != nil {
    log.Fatal(err)
}
fmt.Printf("Valid: %t\n", valid)
```

## Performance

Go provides excellent performance for blockchain operations:

- **Balance Query**: ~50ms
- **Block Number**: ~30ms
- **Key Generation**: <1ms
- **Signature Verification**: <1ms

## Custom RPC

```bash
# Use custom RPC endpoint
RPC_URL=https://mainnet.infura.io/v3/YOUR_KEY go run main.go balance 0x...
```

Modify in code:
```go
utils, err := NewBlockchainUtils("https://your-rpc-endpoint.com")
```

## Supported Networks

Works with any Ethereum-compatible network:

- Ethereum Mainnet
- Goerli, Sepolia
- Polygon
- Arbitrum
- Optimism
- Avalanche C-Chain
- BSC (Binance Smart Chain)
- And more...

## Testing

```bash
go test -v
```

## Building for Production

```bash
# Build optimized binary
go build -ldflags="-s -w" -o blockchain-utils main.go

# Cross-compile for Linux
GOOS=linux GOARCH=amd64 go build -o blockchain-utils-linux main.go

# Cross-compile for macOS
GOOS=darwin GOARCH=arm64 go build -o blockchain-utils-macos main.go

# Cross-compile for Windows
GOOS=windows GOARCH=amd64 go build -o blockchain-utils.exe main.go
```

## Docker

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -ldflags="-s -w" -o blockchain-utils main.go

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/blockchain-utils .
ENTRYPOINT ["./blockchain-utils"]
```

Build and run:
```bash
docker build -t blockchain-utils .
docker run blockchain-utils balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

## Error Handling

All functions return descriptive errors:

```go
balance, err := utils.GetBalance("invalid")
if err != nil {
    // Handle error
    log.Printf("Error: %v", err)
}
```

## Security

- Never commit private keys
- Use environment variables for sensitive data
- Validate all inputs
- Use hardware wallets in production
- Regularly update dependencies

## Resources

- [Go-Ethereum Documentation](https://geth.ethereum.org/docs)
- [Ethereum Go API](https://goethereumbook.org/)
- [Go Concurrency Patterns](https://go.dev/blog/pipelines)

## License

MIT
