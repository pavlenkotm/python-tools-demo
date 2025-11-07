// Wallet connection logic
const connectBtn = document.getElementById('connectBtn');
const modal = document.getElementById('walletModal');
const closeBtn = document.querySelector('.close');
const walletOptions = document.querySelectorAll('.wallet-option');

// Open modal
connectBtn.addEventListener('click', () => {
    modal.style.display = 'block';
});

// Close modal
closeBtn.addEventListener('click', () => {
    modal.style.display = 'none';
});

// Close on outside click
window.addEventListener('click', (e) => {
    if (e.target === modal) {
        modal.style.display = 'none';
    }
});

// Wallet option click handlers
walletOptions.forEach(option => {
    option.addEventListener('click', async () => {
        const walletName = option.textContent.trim();

        if (walletName === 'MetaMask') {
            await connectMetaMask();
        } else {
            alert(`Connecting to ${walletName}...`);
            modal.style.display = 'none';
        }
    });
});

// MetaMask connection
async function connectMetaMask() {
    if (typeof window.ethereum !== 'undefined') {
        try {
            const accounts = await window.ethereum.request({
                method: 'eth_requestAccounts'
            });

            const address = accounts[0];
            const shortAddress = `${address.substring(0, 6)}...${address.substring(38)}`;

            connectBtn.textContent = shortAddress;
            connectBtn.style.background = '#10b981';

            modal.style.display = 'none';

            // Get network
            const chainId = await window.ethereum.request({
                method: 'eth_chainId'
            });
            console.log('Connected to chain:', chainId);

            alert(`Connected: ${shortAddress}`);

        } catch (error) {
            console.error('Connection error:', error);
            alert('Failed to connect wallet');
        }
    } else {
        alert('MetaMask is not installed!');
        window.open('https://metamask.io/download/', '_blank');
    }
}

// Listen for account changes
if (typeof window.ethereum !== 'undefined') {
    window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
            connectBtn.textContent = 'Connect Wallet';
            connectBtn.style.background = '';
        } else {
            const address = accounts[0];
            const shortAddress = `${address.substring(0, 6)}...${address.substring(38)}`;
            connectBtn.textContent = shortAddress;
        }
    });

    window.ethereum.on('chainChanged', () => {
        window.location.reload();
    });
}

// Smooth scroll
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({ behavior: 'smooth' });
        }
    });
});
