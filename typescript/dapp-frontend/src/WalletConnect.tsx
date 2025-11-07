import React, { useState, useEffect } from 'react';
import { ethers } from 'ethers';

interface WalletState {
  address: string | null;
  balance: string | null;
  chainId: number | null;
  isConnected: boolean;
}

const WalletConnect: React.FC = () => {
  const [wallet, setWallet] = useState<WalletState>({
    address: null,
    balance: null,
    chainId: null,
    isConnected: false,
  });
  const [error, setError] = useState<string>('');

  // Check if wallet is already connected
  useEffect(() => {
    checkConnection();
  }, []);

  const checkConnection = async () => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        const provider = new ethers.BrowserProvider(window.ethereum);
        const accounts = await provider.listAccounts();

        if (accounts.length > 0) {
          await updateWalletState(provider);
        }
      } catch (err) {
        console.error('Error checking connection:', err);
      }
    }
  };

  const updateWalletState = async (provider: ethers.BrowserProvider) => {
    try {
      const signer = await provider.getSigner();
      const address = await signer.getAddress();
      const balance = await provider.getBalance(address);
      const network = await provider.getNetwork();

      setWallet({
        address,
        balance: ethers.formatEther(balance),
        chainId: Number(network.chainId),
        isConnected: true,
      });
      setError('');
    } catch (err) {
      setError('Failed to update wallet state');
      console.error(err);
    }
  };

  const connectWallet = async () => {
    if (typeof window.ethereum === 'undefined') {
      setError('MetaMask is not installed!');
      return;
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum);
      await provider.send('eth_requestAccounts', []);
      await updateWalletState(provider);
    } catch (err: any) {
      setError(err.message || 'Failed to connect wallet');
      console.error(err);
    }
  };

  const disconnectWallet = () => {
    setWallet({
      address: null,
      balance: null,
      chainId: null,
      isConnected: false,
    });
  };

  const formatAddress = (addr: string) => {
    return `${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}`;
  };

  const getNetworkName = (chainId: number): string => {
    const networks: Record<number, string> = {
      1: 'Ethereum Mainnet',
      5: 'Goerli Testnet',
      11155111: 'Sepolia Testnet',
      137: 'Polygon Mainnet',
      80001: 'Polygon Mumbai',
    };
    return networks[chainId] || `Chain ID: ${chainId}`;
  };

  return (
    <div className="wallet-connect">
      <h2>Web3 Wallet Connection</h2>

      {error && (
        <div className="error-message">
          {error}
        </div>
      )}

      {!wallet.isConnected ? (
        <button onClick={connectWallet} className="connect-btn">
          Connect Wallet
        </button>
      ) : (
        <div className="wallet-info">
          <div className="info-row">
            <span>Address:</span>
            <span className="address">{formatAddress(wallet.address!)}</span>
          </div>
          <div className="info-row">
            <span>Balance:</span>
            <span>{parseFloat(wallet.balance!).toFixed(4)} ETH</span>
          </div>
          <div className="info-row">
            <span>Network:</span>
            <span>{getNetworkName(wallet.chainId!)}</span>
          </div>
          <button onClick={disconnectWallet} className="disconnect-btn">
            Disconnect
          </button>
        </div>
      )}

      <style>{`
        .wallet-connect {
          max-width: 500px;
          margin: 2rem auto;
          padding: 2rem;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-radius: 12px;
          box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
          color: white;
        }

        h2 {
          margin-top: 0;
          text-align: center;
        }

        .error-message {
          background: rgba(255, 0, 0, 0.2);
          border: 1px solid rgba(255, 0, 0, 0.5);
          padding: 1rem;
          border-radius: 8px;
          margin-bottom: 1rem;
        }

        .connect-btn, .disconnect-btn {
          width: 100%;
          padding: 1rem;
          font-size: 1rem;
          font-weight: bold;
          border: none;
          border-radius: 8px;
          cursor: pointer;
          transition: all 0.3s ease;
        }

        .connect-btn {
          background: white;
          color: #667eea;
        }

        .connect-btn:hover {
          transform: translateY(-2px);
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.2);
        }

        .disconnect-btn {
          background: rgba(255, 255, 255, 0.2);
          color: white;
          margin-top: 1rem;
        }

        .wallet-info {
          background: rgba(255, 255, 255, 0.1);
          padding: 1.5rem;
          border-radius: 8px;
        }

        .info-row {
          display: flex;
          justify-content: space-between;
          padding: 0.75rem 0;
          border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .info-row:last-of-type {
          border-bottom: none;
        }

        .address {
          font-family: monospace;
          font-weight: bold;
        }
      `}</style>
    </div>
  );
};

export default WalletConnect;
