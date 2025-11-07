#!/usr/bin/env python3
"""
Web3.py CLI Tool - Ethereum blockchain interaction utilities
"""

import argparse
import sys
from web3 import Web3
from eth_account import Account
from typing import Optional


class Web3CLI:
    """Command-line interface for Web3 operations"""

    def __init__(self, rpc_url: str = "https://eth.llamarpc.com"):
        """Initialize Web3 connection"""
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        if not self.w3.is_connected():
            raise ConnectionError(f"Failed to connect to {rpc_url}")
        print(f"✅ Connected to Ethereum (Chain ID: {self.w3.eth.chain_id})")

    def get_balance(self, address: str) -> None:
        """Get ETH balance for an address"""
        try:
            checksum_address = self.w3.to_checksum_address(address)
            balance_wei = self.w3.eth.get_balance(checksum_address)
            balance_eth = self.w3.from_wei(balance_wei, 'ether')

            print(f"\n💰 Balance for {checksum_address}")
            print(f"   {balance_eth:.6f} ETH")
            print(f"   {balance_wei:,} Wei")
        except Exception as e:
            print(f"❌ Error: {e}", file=sys.stderr)
            sys.exit(1)

    def get_transaction(self, tx_hash: str) -> None:
        """Get transaction details"""
        try:
            tx = self.w3.eth.get_transaction(tx_hash)
            receipt = self.w3.eth.get_transaction_receipt(tx_hash)

            print(f"\n📝 Transaction: {tx_hash}")
            print(f"   From:     {tx['from']}")
            print(f"   To:       {tx['to']}")
            print(f"   Value:    {self.w3.from_wei(tx['value'], 'ether')} ETH")
            print(f"   Gas:      {tx['gas']:,}")
            print(f"   Gas Price: {self.w3.from_wei(tx['gasPrice'], 'gwei')} Gwei")
            print(f"   Block:    {tx['blockNumber']}")
            print(f"   Status:   {'✅ Success' if receipt['status'] == 1 else '❌ Failed'}")
        except Exception as e:
            print(f"❌ Error: {e}", file=sys.stderr)
            sys.exit(1)

    def get_block(self, block_number: Optional[int] = None) -> None:
        """Get block information"""
        try:
            if block_number is None:
                block = self.w3.eth.get_block('latest')
                print("\n📦 Latest Block")
            else:
                block = self.w3.eth.get_block(block_number)
                print(f"\n📦 Block #{block_number}")

            print(f"   Number:       {block['number']:,}")
            print(f"   Hash:         {block['hash'].hex()}")
            print(f"   Timestamp:    {block['timestamp']}")
            print(f"   Transactions: {len(block['transactions'])}")
            print(f"   Gas Used:     {block['gasUsed']:,}")
            print(f"   Gas Limit:    {block['gasLimit']:,}")
        except Exception as e:
            print(f"❌ Error: {e}", file=sys.stderr)
            sys.exit(1)

    def create_account(self) -> None:
        """Generate a new Ethereum account"""
        account = Account.create()
        print("\n🔐 New Account Generated")
        print(f"   Address:     {account.address}")
        print(f"   Private Key: {account.key.hex()}")
        print("\n⚠️  WARNING: Store the private key securely and never share it!")

    def check_contract(self, address: str) -> None:
        """Check if address is a contract"""
        try:
            checksum_address = self.w3.to_checksum_address(address)
            code = self.w3.eth.get_code(checksum_address)

            is_contract = len(code) > 0
            print(f"\n🔍 Address Analysis: {checksum_address}")
            print(f"   Type: {'📄 Smart Contract' if is_contract else '👤 EOA (Externally Owned Account)'}")
            if is_contract:
                print(f"   Code Size: {len(code)} bytes")
        except Exception as e:
            print(f"❌ Error: {e}", file=sys.stderr)
            sys.exit(1)

    def get_gas_price(self) -> None:
        """Get current gas price"""
        try:
            gas_price_wei = self.w3.eth.gas_price
            gas_price_gwei = self.w3.from_wei(gas_price_wei, 'gwei')

            print("\n⛽ Current Gas Price")
            print(f"   {gas_price_gwei:.2f} Gwei")
            print(f"   {gas_price_wei:,} Wei")

            # Estimate costs for common operations
            print("\n💸 Estimated Transaction Costs:")
            print(f"   Simple Transfer (21,000 gas): {self.w3.from_wei(21000 * gas_price_wei, 'ether'):.6f} ETH")
            print(f"   Token Transfer (65,000 gas):  {self.w3.from_wei(65000 * gas_price_wei, 'ether'):.6f} ETH")
        except Exception as e:
            print(f"❌ Error: {e}", file=sys.stderr)
            sys.exit(1)


def main():
    """Main CLI entry point"""
    parser = argparse.ArgumentParser(
        description="Web3.py CLI - Ethereum blockchain utilities",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s balance 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
  %(prog)s tx 0x1234...
  %(prog)s block 18000000
  %(prog)s block
  %(prog)s gas
  %(prog)s create
  %(prog)s contract 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
        """
    )

    parser.add_argument(
        '--rpc',
        default='https://eth.llamarpc.com',
        help='RPC endpoint URL (default: LlamaRPC)'
    )

    subparsers = parser.add_subparsers(dest='command', required=True)

    # Balance command
    balance_parser = subparsers.add_parser('balance', help='Get ETH balance')
    balance_parser.add_argument('address', help='Ethereum address')

    # Transaction command
    tx_parser = subparsers.add_parser('tx', help='Get transaction details')
    tx_parser.add_argument('hash', help='Transaction hash')

    # Block command
    block_parser = subparsers.add_parser('block', help='Get block information')
    block_parser.add_argument('number', nargs='?', type=int, help='Block number (default: latest)')

    # Gas command
    subparsers.add_parser('gas', help='Get current gas price')

    # Create account command
    subparsers.add_parser('create', help='Generate new account')

    # Contract check command
    contract_parser = subparsers.add_parser('contract', help='Check if address is contract')
    contract_parser.add_argument('address', help='Ethereum address')

    args = parser.parse_args()

    try:
        cli = Web3CLI(rpc_url=args.rpc)

        if args.command == 'balance':
            cli.get_balance(args.address)
        elif args.command == 'tx':
            cli.get_transaction(args.hash)
        elif args.command == 'block':
            cli.get_block(args.number)
        elif args.command == 'gas':
            cli.get_gas_price()
        elif args.command == 'create':
            cli.create_account()
        elif args.command == 'contract':
            cli.check_contract(args.address)

    except ConnectionError as e:
        print(f"❌ Connection Error: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n👋 Interrupted by user")
        sys.exit(0)


if __name__ == "__main__":
    main()
