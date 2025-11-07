# ERC-721 NFT Implementation

A complete ERC-721 NFT implementation with URI storage, minting, and supply management.

## Features

- Standard ERC-721 functionality
- Token URI storage for metadata
- Configurable max supply
- Configurable mint price
- Owner minting (free)
- Public minting (paid)
- Withdraw function for collected funds
- Event emission for minting

## Contract: SimpleNFT

### Constructor Parameters

- `name`: NFT collection name (e.g., "CryptoArt")
- `symbol`: Collection symbol (e.g., "CART")
- `_maxSupply`: Maximum number of NFTs
- `_mintPrice`: Price in wei to mint (public)

### Functions

- `mint(address to, string memory uri)`: Public mint (requires payment)
- `ownerMint(address to, string memory uri)`: Owner mint (free)
- `withdraw()`: Withdraw contract balance (owner only)
- `setMintPrice(uint256 newPrice)`: Update mint price (owner only)
- `totalSupply()`: Get current minted count
- Standard ERC-721: `transferFrom`, `approve`, `balanceOf`, etc.

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

## Usage Example

```solidity
// Deploy
SimpleNFT nft = new SimpleNFT("MyNFT", "MNFT", 10000, 0.01 ether);

// Owner mint
nft.ownerMint(address1, "ipfs://QmHash1");

// Public mint
nft.mint{value: 0.01 ether}(address2, "ipfs://QmHash2");

// Check total supply
uint256 minted = nft.totalSupply();
```

## Metadata

Token URIs typically point to IPFS or centralized storage with JSON metadata:

```json
{
  "name": "NFT #1",
  "description": "My awesome NFT",
  "image": "ipfs://QmImageHash",
  "attributes": [
    {"trait_type": "Rarity", "value": "Legendary"}
  ]
}
```

## Security Features

- Max supply enforcement
- Payment verification
- Owner-only administrative functions
- Safe transfer checks
- OpenZeppelin audited base contracts

## Gas Optimization Tips

- Use `_safeMint` only when needed (external contracts)
- Consider batch minting for multiple NFTs
- Store minimal data on-chain
- Use IPFS for metadata and images

## License

MIT
