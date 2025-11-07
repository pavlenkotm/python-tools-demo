# Web3j Backend Service

Enterprise-grade Ethereum blockchain service built with Web3j for Java applications.

## Features

- Balance queries
- Transaction retrieval
- Block information
- Contract detection
- Gas price monitoring
- Chain ID verification
- Production-ready error handling

## Tech Stack

- **Java 11+**
- **Web3j 4.10** - Ethereum library
- **Maven** - Build tool
- **SLF4J** - Logging

## Installation

```bash
# Build with Maven
mvn clean install

# Run
java -jar target/blockchain-service-1.0.0.jar
```

## Usage

### As a Library

```java
import com.web3.BlockchainService;

public class App {
    public static void main(String[] args) {
        BlockchainService service = new BlockchainService("https://eth.llamarpc.com");

        try {
            // Get balance
            BigDecimal balance = service.getBalance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
            System.out.println("Balance: " + balance + " ETH");

            // Get block number
            BigInteger blockNum = service.getBlockNumber();
            System.out.println("Block: " + blockNum);

            // Check if contract
            boolean isContract = service.isContract("0x...");
            System.out.println("Is Contract: " + isContract);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            service.shutdown();
        }
    }
}
```

### Run Demo

```bash
mvn exec:java -Dexec.mainClass="com.web3.BlockchainService"
```

Output:
```
=== Blockchain Service Demo ===

Chain ID: 1
Latest Block: 18500000
Balance: 1.234567 ETH
Is Contract: true
Gas Price: 25.5 Gwei
Client Version: Geth/v1.13.0
```

## API Reference

### BlockchainService

```java
// Constructor
BlockchainService(String rpcUrl)

// Methods
BigDecimal getBalance(String address)
BigInteger getBlockNumber()
BigInteger getChainId()
Optional<Transaction> getTransaction(String txHash)
Optional<TransactionReceipt> getTransactionReceipt(String txHash)
EthBlock.Block getBlock(BigInteger blockNumber)
boolean isContract(String address)
BigInteger getGasPrice()
String getNetworkVersion()
void shutdown()
```

## Spring Boot Integration

```java
@Configuration
public class Web3Config {

    @Bean
    public BlockchainService blockchainService() {
        return new BlockchainService("https://eth.llamarpc.com");
    }
}

@Service
public class WalletService {

    @Autowired
    private BlockchainService blockchain;

    public BigDecimal getUserBalance(String address) throws IOException {
        return blockchain.getBalance(address);
    }
}
```

## Testing

```bash
mvn test
```

Example test:

```java
@Test
public void testGetBalance() throws IOException {
    BlockchainService service = new BlockchainService("https://eth.llamarpc.com");
    BigDecimal balance = service.getBalance("0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb");
    assertNotNull(balance);
    assertTrue(balance.compareTo(BigDecimal.ZERO) >= 0);
}
```

## Error Handling

All methods throw `IOException` on errors:

```java
try {
    BigDecimal balance = service.getBalance(address);
} catch (IOException e) {
    // Handle network errors, invalid responses, etc.
    logger.error("Failed to get balance", e);
}
```

## Performance

Async operations for high throughput:

```java
CompletableFuture<BigDecimal> balanceFuture = CompletableFuture.supplyAsync(() -> {
    try {
        return service.getBalance(address);
    } catch (IOException e) {
        throw new CompletionException(e);
    }
});
```

## Smart Contract Interaction

Load and interact with contracts:

```java
String contractAddress = "0x...";
Web3j web3j = Web3j.build(new HttpService(rpcUrl));

// Load contract
YourContract contract = YourContract.load(
    contractAddress,
    web3j,
    credentials,
    new DefaultGasProvider()
);

// Call function
BigInteger value = contract.getValue().send();
```

## Transaction Sending

```java
Credentials credentials = Credentials.create("PRIVATE_KEY");

RawTransaction rawTransaction = RawTransaction.createEtherTransaction(
    nonce,
    gasPrice,
    gasLimit,
    toAddress,
    value
);

byte[] signedMessage = TransactionEncoder.signMessage(rawTransaction, chainId, credentials);
String hexValue = Numeric.toHexString(signedMessage);

EthSendTransaction response = web3j.ethSendRawTransaction(hexValue).send();
String txHash = response.getTransactionHash();
```

## Docker

```dockerfile
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package

FROM eclipse-temurin:11-jre-alpine
WORKDIR /app
COPY --from=build /app/target/blockchain-service-1.0.0.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build and run:
```bash
docker build -t blockchain-service .
docker run blockchain-service
```

## Deployment

### JAR Deployment

```bash
mvn clean package
java -jar target/blockchain-service-1.0.0.jar
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blockchain-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: blockchain
  template:
    metadata:
      labels:
        app: blockchain
    spec:
      containers:
      - name: blockchain
        image: blockchain-service:1.0.0
        env:
        - name: RPC_URL
          value: "https://eth.llamarpc.com"
```

## Resources

- [Web3j Documentation](https://docs.web3j.io/)
- [Ethereum JSON-RPC](https://ethereum.org/en/developers/docs/apis/json-rpc/)
- [Java Best Practices](https://docs.oracle.com/en/java/)

## License

MIT
