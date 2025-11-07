# Vyper Smart Contract

Simple ETH vault implementation in Vyper - a Pythonic language for EVM smart contracts.

## What is Vyper?

Vyper is a contract-oriented, pythonic programming language that targets the Ethereum Virtual Machine (EVM).

### Key Differences from Solidity

| Feature | Vyper | Solidity |
|---------|-------|----------|
| Syntax | Python-like | JavaScript-like |
| Complexity | Intentionally limited | Feature-rich |
| Inheritance | ❌ Not supported | ✅ Supported |
| Modifiers | ❌ Not supported | ✅ Supported |
| Inline Assembly | ❌ Not allowed | ✅ Supported |
| Security Focus | Audibility first | Flexibility first |

## Features

- ETH deposit and withdrawal
- Balance tracking
- Pause/unpause functionality
- Ownership management
- Event logging
- Percentage calculations

## Contract: SimpleVault

### Functions

- `deposit()` - Deposit ETH (payable)
- `withdraw(amount)` - Withdraw ETH
- `get_balance(account)` - Check balance
- `pause()` - Pause contract (owner only)
- `unpause()` - Unpause contract (owner only)
- `transfer_ownership(new_owner)` - Transfer ownership

## Installation

```bash
# Install Vyper
pip install vyper

# Verify installation
vyper --version
```

## Compile

```bash
vyper SimpleVault.vy
```

Output: EVM bytecode

### Compile with ABI

```bash
vyper -f abi SimpleVault.vy > SimpleVault.abi
vyper -f bytecode SimpleVault.vy > SimpleVault.bin
```

## Deploy

### Using Brownie

```bash
pip install eth-brownie

brownie console --network mainnet-fork

>>> vault = SimpleVault.deploy({'from': accounts[0]})
>>> vault.deposit({'from': accounts[1], 'value': '1 ether'})
>>> vault.get_balance(accounts[1])
```

### Using Hardhat

```javascript
const { ethers } = require("hardhat");

async function main() {
  const Vault = await ethers.getContractFactory("SimpleVault");
  const vault = await Vault.deploy();
  await vault.deployed();

  console.log("Vault deployed to:", vault.address);
}
```

## Usage Example

```python
# Using Web3.py
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))

# Compile contract
with open('SimpleVault.vy') as f:
    source = f.read()

# Deploy
Vault = w3.eth.contract(abi=abi, bytecode=bytecode)
tx_hash = Vault.constructor().transact()
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
vault = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

# Deposit
vault.functions.deposit().transact({'value': w3.to_wei(1, 'ether')})

# Check balance
balance = vault.functions.get_balance(account).call()
```

## Security Features

### Built-in Safety

- No inline assembly (reduces attack surface)
- Bounds checking on arrays
- Integer overflow/underflow protection
- No recursive calls by default
- No class inheritance (prevents complexity)

### Best Practices Enforced

- Explicit function visibility
- Clear state mutability
- Simple control flow
- Readable code structure

## Testing

Create `test_vault.py`:

```python
import pytest
from brownie import SimpleVault, accounts, reverts

@pytest.fixture
def vault():
    return accounts[0].deploy(SimpleVault)

def test_deposit(vault):
    vault.deposit({'from': accounts[1], 'value': '1 ether'})
    assert vault.get_balance(accounts[1]) == 1e18

def test_withdraw(vault):
    vault.deposit({'from': accounts[1], 'value': '1 ether'})
    vault.withdraw(5e17, {'from': accounts[1]})
    assert vault.get_balance(accounts[1]) == 5e17

def test_pause(vault):
    vault.pause({'from': accounts[0]})
    with reverts("Contract is paused"):
        vault.deposit({'from': accounts[1], 'value': '1 ether'})
```

Run tests:
```bash
brownie test -v
```

## Gas Comparison

Typical gas costs compared to Solidity:

| Operation | Vyper | Solidity |
|-----------|-------|----------|
| Deploy | ~350k | ~380k |
| Deposit | ~45k | ~48k |
| Withdraw | ~35k | ~38k |

Vyper often produces slightly more efficient bytecode due to its simplicity.

## Advantages of Vyper

1. **Auditability**: Python-like syntax is easy to read
2. **Security**: Limited features reduce attack vectors
3. **Simplicity**: No complex inheritance chains
4. **Compiler**: Strong type checking
5. **Community**: Growing adoption in DeFi

## When to Use Vyper

✅ **Good for:**
- Simple contracts
- Security-critical applications
- DeFi protocols
- Teams familiar with Python

❌ **Not ideal for:**
- Complex contract systems
- Heavy use of inheritance
- Projects needing modifiers

## Tools & Frameworks

- **Brownie**: Python-based development framework
- **Ape**: Next-gen framework for Vyper
- **Titanoboa**: Vyper interpreter
- **Hardhat-Vyper**: Vyper plugin for Hardhat

## Resources

- [Vyper Documentation](https://docs.vyperlang.org/)
- [Vyper by Example](https://vyper-by-example.org/)
- [Curve Finance](https://github.com/curvefi/curve-contract) - Major Vyper user
- [Yearn Finance](https://github.com/yearn/yearn-vaults) - Vyper vaults

## License

MIT
