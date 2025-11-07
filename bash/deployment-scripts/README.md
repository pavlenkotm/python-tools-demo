# Bash Deployment Scripts

Production-ready shell scripts for Ethereum node management and smart contract deployment.

## Scripts

### 1. deploy-contract.sh

Automated smart contract deployment supporting multiple frameworks.

**Features:**
- Auto-detects Hardhat, Foundry, or Truffle
- Network configuration
- Contract verification on Etherscan
- Error handling and logging

**Usage:**

```bash
# Deploy to localhost
./deploy-contract.sh

# Deploy to mainnet
./deploy-contract.sh --network mainnet --verify

# Custom RPC
export PRIVATE_KEY="0x..."
export RPC_URL="https://eth.llamarpc.com"
./deploy-contract.sh --network mainnet
```

### 2. node-monitor.sh

Ethereum node health monitoring and alerting.

**Features:**
- Real-time block monitoring
- Sync status checking
- Peer count tracking
- Gas price monitoring
- Stall detection
- Email alerts

**Usage:**

```bash
# One-time health check
./node-monitor.sh check

# Continuous monitoring
./node-monitor.sh monitor

# With custom settings
export RPC_URL="http://localhost:8545"
export CHECK_INTERVAL=5
export ALERT_EMAIL="admin@example.com"
./node-monitor.sh monitor
```

## Installation

```bash
# Make scripts executable
chmod +x *.sh

# Install dependencies
# jq for JSON parsing
sudo apt-get install jq curl
```

## Environment Variables

### deploy-contract.sh

| Variable | Description | Default |
|----------|-------------|---------|
| `NETWORK` | Deployment network | `localhost` |
| `PRIVATE_KEY` | Deployer private key | - |
| `RPC_URL` | RPC endpoint | `http://localhost:8545` |
| `ETHERSCAN_API_KEY` | For contract verification | - |

### node-monitor.sh

| Variable | Description | Default |
|----------|-------------|---------|
| `RPC_URL` | Node RPC endpoint | `http://localhost:8545` |
| `CHECK_INTERVAL` | Monitoring interval (seconds) | `10` |
| `ALERT_EMAIL` | Email for alerts | - |

## Examples

### Deploy with Foundry

```bash
#!/bin/bash

export PRIVATE_KEY="0x..."
export RPC_URL="https://eth.llamarpc.com"
export ETHERSCAN_API_KEY="your-key"

cd solidity/erc20
../../bash/deployment-scripts/deploy-contract.sh \
    --network mainnet \
    --verify
```

### Monitor Node Health

```bash
#!/bin/bash

# Monitor Geth node
export RPC_URL="http://localhost:8545"

watch -n 10 './node-monitor.sh check'
```

### Production Deployment Pipeline

```bash
#!/bin/bash
set -e

echo "🚀 Starting deployment pipeline..."

# 1. Run tests
echo "Running tests..."
forge test

# 2. Compile contracts
echo "Compiling..."
forge build

# 3. Deploy to testnet
echo "Deploying to testnet..."
export NETWORK="goerli"
./deploy-contract.sh

# 4. Verify deployment
echo "Verifying..."
./deploy-contract.sh --verify

# 5. Monitor for issues
echo "Starting monitoring..."
./node-monitor.sh monitor &

echo "✅ Deployment complete!"
```

## Monitoring Output

```
=== Ethereum Node Health Check ===
Timestamp: Mon Nov  7 10:30:00 UTC 2025

✓ Node is responding
  Block Number: 18500000
✓ Node is synced
✓ Peer Count: 25
✓ Gas Price: 25 Gwei
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy Contract

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install dependencies
        run: sudo apt-get install -y jq curl

      - name: Deploy
        env:
          PRIVATE_KEY: ${{ secrets.PRIVATE_KEY }}
          RPC_URL: ${{ secrets.RPC_URL }}
          ETHERSCAN_API_KEY: ${{ secrets.ETHERSCAN_API_KEY }}
        run: bash/deployment-scripts/deploy-contract.sh --network mainnet --verify
```

### Docker

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    jq \
    nodejs \
    npm

COPY deployment-scripts /scripts
WORKDIR /scripts

RUN chmod +x *.sh

CMD ["./node-monitor.sh", "monitor"]
```

## Systemd Service

Create `/etc/systemd/system/node-monitor.service`:

```ini
[Unit]
Description=Ethereum Node Monitor
After=network.target

[Service]
Type=simple
User=ethereum
Environment="RPC_URL=http://localhost:8545"
Environment="CHECK_INTERVAL=30"
ExecStart=/opt/scripts/node-monitor.sh monitor
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable node-monitor
sudo systemctl start node-monitor
sudo systemctl status node-monitor
```

## Best Practices

1. **Always use environment variables for secrets**
2. **Test on testnet before mainnet**
3. **Verify contracts after deployment**
4. **Monitor node health continuously**
5. **Set up alerts for critical failures**
6. **Keep logs for debugging**
7. **Use version control for scripts**

## Troubleshooting

### Connection Errors

```bash
# Test RPC connection
curl -X POST $RPC_URL \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

### Permission Issues

```bash
chmod +x deploy-contract.sh
chmod +x node-monitor.sh
```

### Missing Dependencies

```bash
# Ubuntu/Debian
sudo apt-get install jq curl

# macOS
brew install jq curl
```

## License

MIT
