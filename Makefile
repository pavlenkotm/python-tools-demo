.PHONY: help test build clean

help:
	@echo "Web3 Multi-Language Playground - Makefile Commands"
	@echo ""
	@echo "Available commands:"
	@echo "  make test       - Run all tests"
	@echo "  make build      - Build all projects"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make format     - Format code"

test:
	@echo "Running Python tests..."
	cd python/web3-tools && python -m pytest || true
	@echo "Running Rust tests..."
	cd rust/solana-program && cargo test || true
	@echo "Running Go tests..."
	cd go/blockchain-utils && go test ./... || true

build:
	@echo "Building Rust..."
	cd rust/solana-program && cargo build
	@echo "Building Go..."
	cd go/blockchain-utils && go build
	@echo "Building TypeScript..."
	cd typescript/dapp-frontend && npm install && npm run build

clean:
	@echo "Cleaning build artifacts..."
	find . -name "target" -type d -exec rm -rf {} + || true
	find . -name "node_modules" -type d -exec rm -rf {} + || true
	find . -name "__pycache__" -type d -exec rm -rf {} + || true
	find . -name "dist" -type d -exec rm -rf {} + || true

format:
	@echo "Formatting Python..."
	find python -name "*.py" -exec black {} +
	@echo "Formatting Rust..."
	cd rust/solana-program && cargo fmt
	@echo "Formatting Go..."
	cd go/blockchain-utils && go fmt ./...
