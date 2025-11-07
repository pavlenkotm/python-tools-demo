# Aptos Move Smart Contract

Simple token implementation in Move language for the Aptos blockchain.

## Features

- Token initialization with metadata
- Transfer functionality
- Balance queries
- Minting (owner only)
- Burning tokens
- Full test coverage
- View functions for on-chain data

## Move Language

Move is a resource-oriented programming language designed for safe asset management on blockchains.

### Key Concepts

- **Resources**: Cannot be copied or dropped, ensuring asset safety
- **Abilities**: Control what operations can be performed on structs
- **Generics**: Enable code reuse while maintaining type safety
- **Move Prover**: Formal verification for correctness

## Installation

```bash
# Install Aptos CLI
curl -fsSL "https://aptos.dev/scripts/install_cli.py" | python3

# Verify installation
aptos --version
```

## Compile

```bash
aptos move compile
```

## Test

```bash
aptos move test
```

Output:
```
Running Move unit tests
[ PASS    ] 0x1::simple_token::test_initialize
[ PASS    ] 0x1::simple_token::test_transfer
Test result: OK. Total tests: 2; passed: 2; failed: 0
```

## Deploy

```bash
# Initialize account
aptos init

# Publish module
aptos move publish --named-addresses aptos_token=default
```

## Usage

### Initialize Token

```bash
aptos move run \
  --function-id default::simple_token::initialize \
  --args string:"MyToken" string:"MTK" u8:8 u64:1000000
```

### Transfer Tokens

```bash
aptos move run \
  --function-id default::simple_token::transfer \
  --args address:0x123... u64:100
```

### Query Balance

```bash
aptos move view \
  --function-id default::simple_token::balance_of \
  --args address:0x123...
```

## Contract Functions

### Entry Functions

- `initialize(name, symbol, decimals, initial_supply)` - Deploy token
- `transfer(to, amount)` - Transfer tokens
- `mint(to, amount)` - Mint new tokens (owner only)
- `burn(amount)` - Burn tokens

### View Functions

- `balance_of(address)` - Get token balance
- `name(token_addr)` - Get token name
- `symbol(token_addr)` - Get token symbol
- `total_supply(token_addr)` - Get total supply

## Integration Example

```move
use aptos_token::simple_token;

// Transfer tokens
simple_token::transfer(&signer, recipient_address, 1000);

// Check balance
let balance = simple_token::balance_of(address);
```

## Security Features

- Resource safety (no double-spending)
- Ownership verification
- Balance validation
- Integer overflow protection
- Formal verification support

## Testing

Unit tests are included in the module:

```move
#[test(account = @0x1)]
public fun test_initialize(account: signer) {
    // Test initialization
}

#[test(from = @0x1, to = @0x2)]
public fun test_transfer(from: signer, to: signer) {
    // Test transfers
}
```

## Move Prover

Verify correctness with Move Prover:

```bash
aptos move prove
```

Add specifications:

```move
spec transfer {
    ensures balance_of(from_addr) == old(balance_of(from_addr)) - amount;
    ensures balance_of(to_addr) == old(balance_of(to_addr)) + amount;
}
```

## Gas Costs

Approximate gas costs on Aptos:

- Initialize: ~500 gas
- Transfer: ~200 gas
- Mint: ~300 gas
- View: Free (read-only)

## Differences from Solidity

| Feature | Solidity | Move |
|---------|----------|------|
| Resources | No built-in | First-class resources |
| Safety | Runtime checks | Compile-time + runtime |
| Verification | External tools | Built-in prover |
| Storage | Storage slots | Global storage |
| Generics | Limited | Full support |

## Resources

- [Move Language Book](https://move-language.github.io/move/)
- [Aptos Developer Docs](https://aptos.dev/)
- [Move Tutorial](https://github.com/aptos-labs/aptos-core/tree/main/aptos-move/move-examples)
- [Move Prover Guide](https://github.com/move-language/move/tree/main/language/move-prover)

## License

MIT
