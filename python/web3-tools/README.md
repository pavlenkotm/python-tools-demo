# Web3.py CLI Tools

Professional command-line utilities for Ethereum blockchain interaction using Web3.py.

## Features

- ✅ Check ETH balances
- 📝 Get transaction details
- 📦 Fetch block information
- ⛽ Monitor gas prices
- 🔐 Generate new accounts
- 🔍 Detect smart contracts
- 🌐 Custom RPC endpoint support

## Installation

```bash
# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

## Usage

### Check Balance

```bash
python web3_cli.py balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

Output:
```
✅ Connected to Ethereum (Chain ID: 1)

💰 Balance for 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
   1.234567 ETH
   1,234,567,000,000,000,000 Wei
```

### Get Transaction

```bash
python web3_cli.py tx 0x1234567890abcdef...
```

### Get Block

```bash
# Latest block
python web3_cli.py block

# Specific block
python web3_cli.py block 18000000
```

### Check Gas Price

```bash
python web3_cli.py gas
```

Output:
```
⛽ Current Gas Price
   25.50 Gwei
   25,500,000,000 Wei

💸 Estimated Transaction Costs:
   Simple Transfer (21,000 gas): 0.000536 ETH
   Token Transfer (65,000 gas):  0.001658 ETH
```

### Generate Account

```bash
python web3_cli.py create
```

⚠️ **Warning**: Store private keys securely!

### Check if Contract

```bash
python web3_cli.py contract 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
```

## Custom RPC Endpoint

Use any Ethereum RPC provider:

```bash
# Infura
python web3_cli.py --rpc https://mainnet.infura.io/v3/YOUR_KEY balance 0x...

# Alchemy
python web3_cli.py --rpc https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY balance 0x...

# Local node
python web3_cli.py --rpc http://localhost:8545 balance 0x...
```

## Testing

```bash
pytest test_web3_cli.py -v
```

## Advanced Examples

### Batch Balance Check

```bash
#!/bin/bash
addresses=(
  "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
  "0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe"
)

for addr in "${addresses[@]}"; do
  python web3_cli.py balance "$addr"
done
```

### Monitor Gas Prices

```bash
# Check gas every 10 seconds
watch -n 10 'python web3_cli.py gas'
```

## API Reference

### Web3CLI Class

```python
from web3_cli import Web3CLI

# Initialize
cli = Web3CLI(rpc_url="https://eth.llamarpc.com")

# Methods
cli.get_balance("0x...")
cli.get_transaction("0x...")
cli.get_block(18000000)
cli.get_gas_price()
cli.create_account()
cli.check_contract("0x...")
```

## Supported Networks

- Ethereum Mainnet
- Goerli Testnet
- Sepolia Testnet
- Polygon
- Arbitrum
- Optimism
- Any EVM-compatible chain with RPC access

## Error Handling

The CLI provides clear error messages:

```
❌ Error: Invalid address format
❌ Connection Error: Failed to connect to RPC
❌ Error: Transaction not found
```

## Performance

- Async operations for better performance (coming soon)
- Caching for frequently accessed data (coming soon)
- Batch requests support (coming soon)

## Security Best Practices

- Never commit private keys
- Use environment variables for sensitive data
- Validate all user inputs
- Use hardware wallets for production
- Verify contract addresses before interactions

## Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests
4. Submit a pull request

## License

MIT

## Resources

- [Web3.py Documentation](https://web3py.readthedocs.io/)
- [Ethereum JSON-RPC Spec](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [Ethers.js Comparison](https://docs.ethers.org/v6/)
