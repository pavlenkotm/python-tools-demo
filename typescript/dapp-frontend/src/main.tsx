import React from 'react'
import ReactDOM from 'react-dom/client'
import WalletConnect from './WalletConnect'

// Extend window object for ethereum provider
declare global {
  interface Window {
    ethereum?: any
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <WalletConnect />
  </React.StrictMode>,
)
