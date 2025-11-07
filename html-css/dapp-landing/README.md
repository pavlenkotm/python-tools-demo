# Web3 DApp Landing Page

Modern, responsive landing page for Web3 applications with MetaMask integration.

## Features

- Responsive design
- Gradient hero section
- Wallet connection modal
- MetaMask integration
- Smooth animations
- Modern UI/UX
- Mobile-friendly

## Preview

Visit `index.html` in your browser to see the landing page.

## Structure

```
dapp-landing/
├── index.html    # Main HTML structure
├── styles.css    # All styles and animations
├── script.js     # Wallet connection logic
└── README.md     # This file
```

## Usage

### Local Development

```bash
# Simple HTTP server with Python
python3 -m http.server 8000

# Or with Node.js
npx serve

# Visit http://localhost:8000
```

### Deploy

#### Vercel

```bash
npm i -g vercel
vercel
```

#### Netlify

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod
```

#### GitHub Pages

```bash
# Push to gh-pages branch
git subtree push --prefix html-css/dapp-landing origin gh-pages
```

#### IPFS

```bash
# Install IPFS
ipfs add -r .

# Get CID and visit via gateway
# https://ipfs.io/ipfs/<YOUR_CID>
```

## Customization

### Colors

Edit CSS variables in `styles.css`:

```css
:root {
    --primary: #6366f1;
    --secondary: #8b5cf6;
    --dark: #0f172a;
    --light: #f8fafc;
}
```

### Content

Update text in `index.html`:

- Hero title and subtitle
- Feature cards
- Stats numbers
- Footer links

### Wallet Options

Add more wallets in `index.html`:

```html
<button class="wallet-option">
    <span>🦊</span>
    <span>New Wallet</span>
</button>
```

## Wallet Integration

### MetaMask

Automatically detects MetaMask installation:

```javascript
if (typeof window.ethereum !== 'undefined') {
    // MetaMask available
    await window.ethereum.request({
        method: 'eth_requestAccounts'
    });
}
```

### WalletConnect

Add WalletConnect library:

```html
<script src="https://cdn.jsdelivr.net/npm/@walletconnect/web3-provider"></script>
```

```javascript
const provider = new WalletConnectProvider({
    infuraId: "YOUR_INFURA_ID"
});

await provider.enable();
```

## Sections

### Hero

- Gradient background
- Animated floating cards
- CTA buttons
- Wallet connect button

### Features

- 4-column grid (responsive)
- Icon + title + description
- Hover animations

### Stats

- Real-time metrics display
- Gradient numbers
- Dark background

### Footer

- Multi-column links
- Social media
- Copyright

## Animations

### Floating Cards

```css
@keyframes float {
    0%, 100% { transform: translateY(0px); }
    50% { transform: translateY(-20px); }
}
```

### Hover Effects

- Transform scale
- Box shadow
- Color transitions

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Opera (latest)

## Performance

- Optimized CSS
- Minimal JavaScript
- No external dependencies (except Web3)
- Fast load times

## SEO

Includes:
- Meta tags
- Semantic HTML
- Alt attributes
- Proper heading hierarchy

## Accessibility

- ARIA labels
- Keyboard navigation
- Color contrast
- Screen reader support

## Resources

- [Web3.js Documentation](https://web3js.readthedocs.io/)
- [MetaMask Docs](https://docs.metamask.io/)
- [CSS Grid Guide](https://css-tricks.com/snippets/css/complete-guide-grid/)

## License

MIT
