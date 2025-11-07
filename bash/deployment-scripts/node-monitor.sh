#!/bin/bash

# Ethereum Node Monitoring Script
# Monitors node health, sync status, and performance

set -euo pipefail

# Configuration
RPC_URL="${RPC_URL:-http://localhost:8545}"
CHECK_INTERVAL="${CHECK_INTERVAL:-10}"
ALERT_EMAIL="${ALERT_EMAIL:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get current block number
get_block_number() {
    curl -s -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
        | jq -r '.result' \
        | xargs printf "%d\n"
}

# Get sync status
get_sync_status() {
    curl -s -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
        | jq -r '.result'
}

# Get peer count
get_peer_count() {
    curl -s -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
        | jq -r '.result' \
        | xargs printf "%d\n"
}

# Get gas price
get_gas_price() {
    curl -s -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' \
        | jq -r '.result' \
        | xargs printf "%d\n"
}

# Check node health
check_health() {
    local block_number=$(get_block_number 2>/dev/null)
    local peer_count=$(get_peer_count 2>/dev/null)
    local sync_status=$(get_sync_status 2>/dev/null)

    echo -e "${BLUE}=== Ethereum Node Health Check ===${NC}"
    echo -e "${GREEN}Timestamp:${NC} $(date)"
    echo ""

    if [ -n "$block_number" ]; then
        echo -e "${GREEN}✓${NC} Node is responding"
        echo -e "  Block Number: $block_number"
    else
        echo -e "${RED}✗${NC} Node is not responding"
        return 1
    fi

    if [ "$sync_status" == "false" ]; then
        echo -e "${GREEN}✓${NC} Node is synced"
    else
        echo -e "${YELLOW}⚠${NC} Node is syncing"
        echo -e "  Status: $sync_status"
    fi

    echo -e "${GREEN}✓${NC} Peer Count: $peer_count"

    if [ "$peer_count" -lt 3 ]; then
        echo -e "${YELLOW}⚠${NC} Warning: Low peer count"
    fi

    local gas_price=$(get_gas_price 2>/dev/null)
    if [ -n "$gas_price" ]; then
        local gas_gwei=$((gas_price / 1000000000))
        echo -e "${GREEN}✓${NC} Gas Price: $gas_gwei Gwei"
    fi

    echo ""
}

# Monitor continuously
monitor() {
    local last_block=0
    local stalled_count=0

    echo -e "${BLUE}Starting continuous monitoring (interval: ${CHECK_INTERVAL}s)${NC}"
    echo -e "Press Ctrl+C to stop\n"

    while true; do
        local current_block=$(get_block_number 2>/dev/null || echo "0")

        if [ "$current_block" == "0" ]; then
            echo -e "${RED}[$(date +%H:%M:%S)] Node unreachable${NC}"
            stalled_count=$((stalled_count + 1))
        elif [ "$current_block" == "$last_block" ]; then
            stalled_count=$((stalled_count + 1))
            echo -e "${YELLOW}[$(date +%H:%M:%S)] Block: $current_block (stalled: $stalled_count)${NC}"
        else
            stalled_count=0
            echo -e "${GREEN}[$(date +%H:%M:%S)] Block: $current_block ↑${NC}"
        fi

        if [ "$stalled_count" -gt 5 ]; then
            echo -e "${RED}[ALERT] Node has been stalled for $((stalled_count * CHECK_INTERVAL)) seconds${NC}"
            if [ -n "$ALERT_EMAIL" ]; then
                echo "Node stalled at block $current_block" | mail -s "Node Alert" "$ALERT_EMAIL"
            fi
        fi

        last_block=$current_block
        sleep "$CHECK_INTERVAL"
    done
}

# Main
case "${1:-check}" in
    check)
        check_health
        ;;
    monitor)
        monitor
        ;;
    *)
        echo "Usage: $0 {check|monitor}"
        echo ""
        echo "Commands:"
        echo "  check    - Run one-time health check"
        echo "  monitor  - Continuously monitor node"
        echo ""
        echo "Environment Variables:"
        echo "  RPC_URL         - Node RPC endpoint (default: http://localhost:8545)"
        echo "  CHECK_INTERVAL  - Monitoring interval in seconds (default: 10)"
        echo "  ALERT_EMAIL     - Email for alerts (optional)"
        exit 1
        ;;
esac
