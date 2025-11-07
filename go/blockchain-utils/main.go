package main

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"log"
	"math/big"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/ethclient"
)

// BlockchainUtils provides utilities for Ethereum interaction
type BlockchainUtils struct {
	client *ethclient.Client
	ctx    context.Context
}

// NewBlockchainUtils creates a new utility instance
func NewBlockchainUtils(rpcURL string) (*BlockchainUtils, error) {
	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		return nil, fmt.Errorf("failed to connect to %s: %w", rpcURL, err)
	}

	return &BlockchainUtils{
		client: client,
		ctx:    context.Background(),
	}, nil
}

// GetBalance retrieves ETH balance for an address
func (b *BlockchainUtils) GetBalance(address string) (*big.Int, error) {
	account := common.HexToAddress(address)
	balance, err := b.client.BalanceAt(b.ctx, account, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to get balance: %w", err)
	}
	return balance, nil
}

// GetBlockNumber gets the latest block number
func (b *BlockchainUtils) GetBlockNumber() (uint64, error) {
	blockNumber, err := b.client.BlockNumber(b.ctx)
	if err != nil {
		return 0, fmt.Errorf("failed to get block number: %w", err)
	}
	return blockNumber, nil
}

// GetChainID retrieves the chain ID
func (b *BlockchainUtils) GetChainID() (*big.Int, error) {
	chainID, err := b.client.ChainID(b.ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to get chain ID: %w", err)
	}
	return chainID, nil
}

// IsContract checks if an address is a smart contract
func (b *BlockchainUtils) IsContract(address string) (bool, error) {
	account := common.HexToAddress(address)
	bytecode, err := b.client.CodeAt(b.ctx, account, nil)
	if err != nil {
		return false, fmt.Errorf("failed to get code: %w", err)
	}
	return len(bytecode) > 0, nil
}

// GenerateKeyPair generates a new ECDSA key pair
func GenerateKeyPair() (*ecdsa.PrivateKey, string, error) {
	privateKey, err := crypto.GenerateKey()
	if err != nil {
		return nil, "", fmt.Errorf("failed to generate key: %w", err)
	}

	privateKeyBytes := crypto.FromECDSA(privateKey)
	privateKeyHex := hexutil.Encode(privateKeyBytes)

	publicKey := privateKey.Public()
	publicKeyECDSA, ok := publicKey.(*ecdsa.PublicKey)
	if !ok {
		return nil, "", fmt.Errorf("failed to cast public key")
	}

	address := crypto.PubkeyToAddress(*publicKeyECDSA).Hex()

	return privateKey, address, nil
}

// VerifySignature verifies an ECDSA signature
func VerifySignature(message []byte, signature []byte, publicKeyHex string) (bool, error) {
	hash := crypto.Keccak256Hash(message)

	publicKeyBytes, err := hexutil.Decode(publicKeyHex)
	if err != nil {
		return false, fmt.Errorf("invalid public key: %w", err)
	}

	publicKey, err := crypto.UnmarshalPubkey(publicKeyBytes)
	if err != nil {
		return false, fmt.Errorf("failed to unmarshal public key: %w", err)
	}

	sigPublicKey, err := crypto.SigToPub(hash.Bytes(), signature)
	if err != nil {
		return false, fmt.Errorf("failed to recover public key: %w", err)
	}

	matches := publicKey.X.Cmp(sigPublicKey.X) == 0 && publicKey.Y.Cmp(sigPublicKey.Y) == 0

	return matches, nil
}

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage:")
		fmt.Println("  go run main.go balance <address>")
		fmt.Println("  go run main.go block")
		fmt.Println("  go run main.go chain")
		fmt.Println("  go run main.go contract <address>")
		fmt.Println("  go run main.go generate")
		os.Exit(1)
	}

	command := os.Args[1]
	rpcURL := "https://eth.llamarpc.com"

	if command == "generate" {
		// Generate key pair (no RPC needed)
		privateKey, address, err := GenerateKeyPair()
		if err != nil {
			log.Fatalf("❌ Error: %v", err)
		}

		privateKeyBytes := crypto.FromECDSA(privateKey)
		fmt.Println("🔐 New Account Generated")
		fmt.Printf("   Address:     %s\n", address)
		fmt.Printf("   Private Key: %s\n", hexutil.Encode(privateKeyBytes))
		fmt.Println("\n⚠️  WARNING: Store the private key securely!")
		return
	}

	// Commands that need RPC connection
	utils, err := NewBlockchainUtils(rpcURL)
	if err != nil {
		log.Fatalf("❌ Connection Error: %v", err)
	}

	switch command {
	case "balance":
		if len(os.Args) < 3 {
			log.Fatal("❌ Error: address required")
		}
		address := os.Args[2]
		balance, err := utils.GetBalance(address)
		if err != nil {
			log.Fatalf("❌ Error: %v", err)
		}
		ethBalance := new(big.Float).Quo(new(big.Float).SetInt(balance), big.NewFloat(1e18))
		fmt.Printf("💰 Balance: %s ETH\n", ethBalance.Text('f', 6))

	case "block":
		blockNum, err := utils.GetBlockNumber()
		if err != nil {
			log.Fatalf("❌ Error: %v", err)
		}
		fmt.Printf("📦 Latest Block: %d\n", blockNum)

	case "chain":
		chainID, err := utils.GetChainID()
		if err != nil {
			log.Fatalf("❌ Error: %v", err)
		}
		networks := map[int64]string{
			1:        "Ethereum Mainnet",
			5:        "Goerli Testnet",
			11155111: "Sepolia Testnet",
			137:      "Polygon Mainnet",
			80001:    "Polygon Mumbai",
		}
		network := networks[chainID.Int64()]
		if network == "" {
			network = "Unknown"
		}
		fmt.Printf("🌐 Chain ID: %s (%s)\n", chainID.String(), network)

	case "contract":
		if len(os.Args) < 3 {
			log.Fatal("❌ Error: address required")
		}
		address := os.Args[2]
		isContract, err := utils.IsContract(address)
		if err != nil {
			log.Fatalf("❌ Error: %v", err)
		}
		if isContract {
			fmt.Printf("📄 %s is a Smart Contract\n", address)
		} else {
			fmt.Printf("👤 %s is an EOA (Externally Owned Account)\n", address)
		}

	default:
		fmt.Printf("❌ Unknown command: %s\n", command)
		os.Exit(1)
	}
}
