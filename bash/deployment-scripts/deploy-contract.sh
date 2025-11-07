#!/bin/bash

# Ethereum Smart Contract Deployment Script
# Supports Hardhat, Foundry, and Truffle

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
NETWORK="${NETWORK:-localhost}"
PRIVATE_KEY="${PRIVATE_KEY:-}"
RPC_URL="${RPC_URL:-http://localhost:8545}"

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 is not installed"
        exit 1
    fi
}

deploy_with_hardhat() {
    log_info "Deploying with Hardhat..."

    check_command "npx"

    if [ ! -f "hardhat.config.js" ] && [ ! -f "hardhat.config.ts" ]; then
        log_error "hardhat.config.js not found"
        exit 1
    fi

    npx hardhat run scripts/deploy.js --network "$NETWORK"

    log_info "Deployment complete!"
}

deploy_with_foundry() {
    log_info "Deploying with Foundry (Forge)..."

    check_command "forge"

    if [ ! -f "foundry.toml" ]; then
        log_error "foundry.toml not found"
        exit 1
    fi

    if [ -z "$PRIVATE_KEY" ]; then
        log_error "PRIVATE_KEY environment variable not set"
        exit 1
    fi

    forge script script/Deploy.s.sol:Deploy \
        --rpc-url "$RPC_URL" \
        --private-key "$PRIVATE_KEY" \
        --broadcast \
        --verify

    log_info "Deployment complete!"
}

deploy_with_truffle() {
    log_info "Deploying with Truffle..."

    check_command "truffle"

    if [ ! -f "truffle-config.js" ]; then
        log_error "truffle-config.js not found"
        exit 1
    fi

    truffle migrate --network "$NETWORK"

    log_info "Deployment complete!"
}

verify_contract() {
    local address="$1"
    local args="$2"

    log_info "Verifying contract at $address..."

    if command -v forge &> /dev/null; then
        forge verify-contract "$address" \
            --chain-id 1 \
            --constructor-args "$args" \
            --etherscan-api-key "$ETHERSCAN_API_KEY"
    elif command -v npx &> /dev/null; then
        npx hardhat verify --network "$NETWORK" "$address" $args
    else
        log_warn "No verification tool available"
    fi
}

# Main script
main() {
    log_info "=== Smart Contract Deployment Script ==="
    log_info "Network: $NETWORK"
    log_info "RPC URL: $RPC_URL"

    # Detect framework
    if [ -f "foundry.toml" ]; then
        deploy_with_foundry
    elif [ -f "hardhat.config.js" ] || [ -f "hardhat.config.ts" ]; then
        deploy_with_hardhat
    elif [ -f "truffle-config.js" ]; then
        deploy_with_truffle
    else
        log_error "No supported framework detected"
        log_info "Supported: Hardhat, Foundry, Truffle"
        exit 1
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --network)
            NETWORK="$2"
            shift 2
            ;;
        --rpc-url)
            RPC_URL="$2"
            shift 2
            ;;
        --verify)
            VERIFY=true
            shift
            ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --network <name>    Network to deploy to (default: localhost)"
            echo "  --rpc-url <url>     RPC endpoint URL"
            echo "  --verify            Verify contract on Etherscan"
            echo "  --help              Show this help message"
            echo ""
            echo "Environment Variables:"
            echo "  PRIVATE_KEY         Private key for deployment"
            echo "  RPC_URL             RPC endpoint URL"
            echo "  ETHERSCAN_API_KEY   Etherscan API key for verification"
            exit 0
            ;;
        *)
            log_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

main
