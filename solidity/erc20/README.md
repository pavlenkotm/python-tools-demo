# ERC-20 Token Implementation

A standard ERC-20 fungible token implementation using OpenZeppelin contracts.

## Features

- Standard ERC-20 functionality (transfer, approve, allowance)
- Minting capability (owner only)
- Burning functionality
- Configurable decimals
- Built with OpenZeppelin v5.0

## Contract: SimpleToken

### Constructor Parameters

- `name`: Token name (e.g., "MyToken")
- `symbol`: Token symbol (e.g., "MTK")
- `decimals_`: Number of decimals (typically 18)
- `initialSupply`: Initial token supply (before decimals)

### Functions

- `mint(address to, uint256 amount)`: Mint new tokens (owner only)
- `burn(uint256 amount)`: Burn tokens from sender's balance
- Standard ERC-20: `transfer`, `approve`, `transferFrom`, etc.

## Setup

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts@v5.0.0

# Compile
forge build

# Run tests
forge test
```

## Testing

```bash
forge test -vvv
```

## Deployment Example

```bash
forge create SimpleToken \
  --constructor-args "MyToken" "MTK" 18 1000000 \
  --private-key $PRIVATE_KEY \
  --rpc-url $RPC_URL
```

## Security Considerations

- Only owner can mint new tokens
- Uses OpenZeppelin's audited contracts
- Implements standard ERC-20 interface
- No backdoors or hidden functions

## License

MIT
