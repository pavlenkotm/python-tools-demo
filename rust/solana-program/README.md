# Solana Counter Program

A simple on-chain counter program demonstrating Solana smart contract development in Rust.

## Features

- Increment counter
- Decrement counter
- Reset counter
- Full test coverage
- Overflow/underflow protection
- Account ownership validation

## Program Instructions

The program accepts a single-byte instruction:

- `0`: Increment counter by 1
- `1`: Decrement counter by 1
- `2`: Reset counter to 0

## Architecture

```
┌─────────────────┐
│  Client DApp    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Solana Runtime  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Counter Program │ ◄── This code
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Account Storage │ (4 bytes: u32 counter)
└─────────────────┘
```

## Setup

```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Install Solana CLI
sh -c "$(curl -sSfL https://release.solana.com/stable/install)"

# Build the program
cargo build-bpf

# Run tests
cargo test
```

## Testing

The program includes comprehensive unit tests:

```bash
cargo test -- --nocapture
```

Test coverage:
- ✅ Counter increment
- ✅ Counter decrement
- ✅ Counter reset
- ✅ Overflow protection
- ✅ Underflow protection

## Deployment

```bash
# Deploy to devnet
solana program deploy target/deploy/solana_counter.so --url devnet

# Get program ID
solana address -k target/deploy/solana_counter-keypair.json
```

## Usage Example (JavaScript)

```javascript
import { Connection, PublicKey, Transaction, TransactionInstruction } from '@solana/web3.js';

const connection = new Connection('https://api.devnet.solana.com');
const programId = new PublicKey('YOUR_PROGRAM_ID');
const counterAccount = new PublicKey('COUNTER_ACCOUNT');

// Increment counter
const instruction = new TransactionInstruction({
  keys: [{ pubkey: counterAccount, isSigner: false, isWritable: true }],
  programId,
  data: Buffer.from([0]), // 0 = increment
});

const transaction = new Transaction().add(instruction);
await connection.sendTransaction(transaction, [payer]);
```

## Security Considerations

- Program validates account ownership
- Arithmetic operations use checked math (prevents overflow/underflow)
- Minimal attack surface
- No external dependencies

## Program Size

- Compiled size: ~50KB (optimized with LTO)
- Account storage: 4 bytes per counter

## Learn More

- [Solana Program Library](https://spl.solana.com/)
- [Anchor Framework](https://www.anchor-lang.com/)
- [Solana Cookbook](https://solanacookbook.com/)

## License

MIT
