package com.web3;

import org.web3j.protocol.Web3j;
import org.web3j.protocol.core.DefaultBlockParameterName;
import org.web3j.protocol.core.methods.response.*;
import org.web3j.protocol.http.HttpService;
import org.web3j.utils.Convert;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.Optional;

/**
 * Blockchain service for Ethereum interaction using Web3j
 */
public class BlockchainService {

    private final Web3j web3j;

    public BlockchainService(String rpcUrl) {
        this.web3j = Web3j.build(new HttpService(rpcUrl));
    }

    /**
     * Get ETH balance for an address
     */
    public BigDecimal getBalance(String address) throws IOException {
        EthGetBalance balance = web3j.ethGetBalance(address, DefaultBlockParameterName.LATEST).send();

        if (balance.hasError()) {
            throw new IOException("Error getting balance: " + balance.getError().getMessage());
        }

        BigInteger balanceWei = balance.getBalance();
        return Convert.fromWei(new BigDecimal(balanceWei), Convert.Unit.ETHER);
    }

    /**
     * Get current block number
     */
    public BigInteger getBlockNumber() throws IOException {
        EthBlockNumber blockNumber = web3j.ethBlockNumber().send();

        if (blockNumber.hasError()) {
            throw new IOException("Error getting block number: " + blockNumber.getError().getMessage());
        }

        return blockNumber.getBlockNumber();
    }

    /**
     * Get chain ID
     */
    public BigInteger getChainId() throws IOException {
        EthChainId chainId = web3j.ethChainId().send();

        if (chainId.hasError()) {
            throw new IOException("Error getting chain ID: " + chainId.getError().getMessage());
        }

        return chainId.getChainId();
    }

    /**
     * Get transaction by hash
     */
    public Optional<Transaction> getTransaction(String txHash) throws IOException {
        EthTransaction transaction = web3j.ethGetTransactionByHash(txHash).send();

        if (transaction.hasError()) {
            throw new IOException("Error getting transaction: " + transaction.getError().getMessage());
        }

        return transaction.getTransaction();
    }

    /**
     * Get transaction receipt
     */
    public Optional<TransactionReceipt> getTransactionReceipt(String txHash) throws IOException {
        EthGetTransactionReceipt receipt = web3j.ethGetTransactionReceipt(txHash).send();

        if (receipt.hasError()) {
            throw new IOException("Error getting receipt: " + receipt.getError().getMessage());
        }

        return receipt.getTransactionReceipt();
    }

    /**
     * Get block by number
     */
    public EthBlock.Block getBlock(BigInteger blockNumber) throws IOException {
        EthBlock block = web3j.ethGetBlockByNumber(
                org.web3j.protocol.core.DefaultBlockParameter.valueOf(blockNumber),
                false
        ).send();

        if (block.hasError()) {
            throw new IOException("Error getting block: " + block.getError().getMessage());
        }

        return block.getBlock();
    }

    /**
     * Check if address is a smart contract
     */
    public boolean isContract(String address) throws IOException {
        EthGetCode code = web3j.ethGetCode(address, DefaultBlockParameterName.LATEST).send();

        if (code.hasError()) {
            throw new IOException("Error getting code: " + code.getError().getMessage());
        }

        return !code.getCode().equals("0x");
    }

    /**
     * Get current gas price
     */
    public BigInteger getGasPrice() throws IOException {
        EthGasPrice gasPrice = web3j.ethGasPrice().send();

        if (gasPrice.hasError()) {
            throw new IOException("Error getting gas price: " + gasPrice.getError().getMessage());
        }

        return gasPrice.getGasPrice();
    }

    /**
     * Get network version
     */
    public String getNetworkVersion() throws IOException {
        Web3ClientVersion clientVersion = web3j.web3ClientVersion().send();

        if (clientVersion.hasError()) {
            throw new IOException("Error getting client version: " + clientVersion.getError().getMessage());
        }

        return clientVersion.getWeb3ClientVersion();
    }

    /**
     * Close connection
     */
    public void shutdown() {
        web3j.shutdown();
    }

    // Main method for testing
    public static void main(String[] args) {
        String rpcUrl = "https://eth.llamarpc.com";
        BlockchainService service = new BlockchainService(rpcUrl);

        try {
            System.out.println("=== Blockchain Service Demo ===\n");

            // Get chain ID
            BigInteger chainId = service.getChainId();
            System.out.println("Chain ID: " + chainId);

            // Get latest block
            BigInteger blockNumber = service.getBlockNumber();
            System.out.println("Latest Block: " + blockNumber);

            // Get balance
            String testAddress = "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb";
            BigDecimal balance = service.getBalance(testAddress);
            System.out.println("Balance: " + balance + " ETH");

            // Check if contract
            boolean isContract = service.isContract(testAddress);
            System.out.println("Is Contract: " + isContract);

            // Get gas price
            BigInteger gasPrice = service.getGasPrice();
            BigDecimal gasPriceGwei = Convert.fromWei(new BigDecimal(gasPrice), Convert.Unit.GWEI);
            System.out.println("Gas Price: " + gasPriceGwei + " Gwei");

            // Get network version
            String version = service.getNetworkVersion();
            System.out.println("Client Version: " + version);

        } catch (IOException e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        } finally {
            service.shutdown();
        }
    }
}
