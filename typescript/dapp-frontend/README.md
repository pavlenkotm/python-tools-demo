# Web3 DApp Frontend

Modern React + TypeScript DApp with Ethers.js v6 wallet integration.

## Features

- MetaMask wallet connection
- Real-time balance display
- Network detection (Ethereum, Polygon, etc.)
- Address formatting
- Connection state management
- Error handling
- Responsive design with gradient UI

## Tech Stack

- **React 18** - UI framework
- **TypeScript** - Type safety
- **Ethers.js v6** - Ethereum library
- **Vite** - Build tool
- **ESLint** - Code linting

## Installation

```bash
npm install
```

## Development

```bash
npm run dev
```

Visit `http://localhost:5173`

## Build

```bash
npm run build
```

Output: `dist/` folder ready for deployment

## Usage

### Basic Wallet Connection

```tsx
import WalletConnect from './WalletConnect';

function App() {
  return <WalletConnect />;
}
```

### Custom Integration

```typescript
import { ethers } from 'ethers';

// Connect to wallet
const provider = new ethers.BrowserProvider(window.ethereum);
await provider.send('eth_requestAccounts', []);

// Get signer
const signer = await provider.getSigner();
const address = await signer.getAddress();

// Get balance
const balance = await provider.getBalance(address);
console.log(ethers.formatEther(balance));
```

## Supported Networks

- Ethereum Mainnet (Chain ID: 1)
- Goerli Testnet (Chain ID: 5)
- Sepolia Testnet (Chain ID: 11155111)
- Polygon Mainnet (Chain ID: 137)
- Polygon Mumbai (Chain ID: 80001)

## Component API

### WalletConnect

Standalone component with built-in state management.

**State:**
- `address`: Connected wallet address
- `balance`: ETH balance
- `chainId`: Current network chain ID
- `isConnected`: Connection status

## Security Notes

- Always validate user input
- Never store private keys in frontend
- Use HTTPS in production
- Implement proper error boundaries
- Validate contract addresses before transactions

## Browser Requirements

- Modern browser with ES2020 support
- MetaMask or compatible Web3 wallet extension

## Testing

```bash
npm test
```

## Deployment

### Vercel
```bash
npm run build
vercel --prod
```

### IPFS
```bash
npm run build
ipfs add -r dist/
```

### GitHub Pages
```bash
npm run build
# Deploy dist/ folder to gh-pages branch
```

## Future Enhancements

- [ ] WalletConnect integration
- [ ] Multi-wallet support (Coinbase Wallet, Rainbow, etc.)
- [ ] ENS name resolution
- [ ] Transaction history
- [ ] Token balance display (ERC-20)
- [ ] NFT gallery (ERC-721)

## Learn More

- [Ethers.js Documentation](https://docs.ethers.org/v6/)
- [React Documentation](https://react.dev/)
- [Vite Guide](https://vitejs.dev/guide/)

## License

MIT
