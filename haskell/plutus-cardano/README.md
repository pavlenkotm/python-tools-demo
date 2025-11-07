# Plutus Cardano Smart Contract

Vesting contract written in Plutus for the Cardano blockchain.

## What is Plutus?

Plutus is Cardano's smart contract platform based on Haskell, providing:

- Strong type safety
- Formal verification
- Functional programming
- EUTXO model
- Off-chain code alongside on-chain validators

## Features

- Time-locked vesting
- Beneficiary validation
- Claim and cancel operations
- Type-safe on-chain code
- Integrated off-chain logic

## Contract: Vesting

A simple vesting contract that locks funds until a deadline.

### Parameters

```haskell
data VestingParams = VestingParams
    { beneficiary :: PaymentPubKeyHash
    , deadline    :: POSIXTime
    }
```

### Operations

- **Grab**: Lock funds in the contract
- **Claim**: Beneficiary claims after deadline
- **Cancel**: Return funds before deadline

## Installation

```bash
# Install Nix
curl -L https://nixos.org/nix/install | sh

# Clone Plutus
git clone https://github.com/input-output-hk/plutus.git
cd plutus

# Enter Nix shell
nix-shell
```

## Compilation

```bash
cabal build
```

## Testing

```bash
cabal test
```

## Deployment

### Generate Script

```haskell
import Cardano.Api
import Plutus.V2.Ledger.Api

writeValidator :: FilePath -> Validator -> IO ()
writeValidator file validator = do
    let script = PlutusScriptSerialised $ SBS.toShort $ LBS.toStrict $ serialise validator
    writeFileTextEnvelope file Nothing script
```

### Create Transaction

```bash
# Build transaction
cardano-cli transaction build \
  --tx-in <UTXO> \
  --tx-out <SCRIPT_ADDRESS>+<AMOUNT> \
  --tx-out-datum-hash <DATUM_HASH> \
  --change-address <YOUR_ADDRESS> \
  --out-file vesting.raw

# Sign transaction
cardano-cli transaction sign \
  --tx-body-file vesting.raw \
  --signing-key-file payment.skey \
  --mainnet \
  --out-file vesting.signed

# Submit transaction
cardano-cli transaction submit \
  --tx-file vesting.signed \
  --mainnet
```

## Key Concepts

### EUTXO Model

Unlike Ethereum's account model, Cardano uses Extended UTXO:

| Feature | Ethereum | Cardano |
|---------|----------|---------|
| Model | Account-based | EUTXO |
| State | Global | Per UTXO |
| Parallelism | Limited | High |
| Determinism | Depends | Guaranteed |

### Validators

```haskell
mkValidator :: Datum -> Redeemer -> ScriptContext -> Bool
```

- **Datum**: Data stored with UTXO
- **Redeemer**: Data provided when spending
- **ScriptContext**: Transaction info

### Off-chain Code

Plutus includes off-chain code:

```haskell
grab :: Contract () VestingSchema Text ()
claim :: Contract () VestingSchema Text ()
```

## Example Usage

```haskell
-- Create vesting params
let params = VestingParams
        { beneficiary = paymentPubKeyHash "addr1..."
        , deadline = POSIXTime 1700000000
        }

-- Lock 100 ADA
grab params 100_000_000

-- Wait for deadline...

-- Claim funds
claim params
```

## Testing with Emulator

```haskell
test :: IO ()
test = runEmulatorTraceIO $ do
    h1 <- activateContractWallet (knownWallet 1) endpoints
    h2 <- activateContractWallet (knownWallet 2) endpoints
    callEndpoint @"grab" h1 100
    void $ Emulator.waitNSlots 10
    callEndpoint @"claim" h2 ()
```

## Advantages of Plutus

1. **Type Safety**: Haskell's type system prevents errors
2. **Formal Verification**: Mathematical proof of correctness
3. **No Surprises**: Deterministic execution
4. **Lower Costs**: Predictable fees
5. **Security**: Fewer attack vectors

## Comparison with Solidity

```
┌─────────────────┬──────────────┬────────────┐
│ Feature         │ Solidity     │ Plutus     │
├─────────────────┼──────────────┼────────────┤
│ Language        │ JavaScript   │ Haskell    │
│ Typing          │ Dynamic      │ Static     │
│ Verification    │ External     │ Built-in   │
│ Gas Costs       │ Variable     │ Predictable│
│ Parallelism     │ Limited      │ High       │
└─────────────────┴──────────────┴────────────┘
```

## Resources

- [Plutus Pioneer Program](https://github.com/input-output-hk/plutus-pioneer-program)
- [Plutus Documentation](https://plutus.readthedocs.io/)
- [Cardano Docs](https://docs.cardano.org/)
- [Marlowe (DSL)](https://marlowe-finance.io/)

## Common Patterns

### Time locks
```haskell
mustValidateIn (from deadline)
```

### Multi-signature
```haskell
all (txSignedBy info) requiredSigners
```

### Token minting
```haskell
txInfoMint info == expectedValue
```

## License

MIT
