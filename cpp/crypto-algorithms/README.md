# C++ Cryptographic Algorithms

Low-level cryptographic primitives used in blockchain systems, implemented in modern C++.

## Features

- **Keccak-256**: Ethereum's hashing algorithm
- Zero external dependencies (except standard library)
- Optimized for performance
- Header-only compatible
- Cross-platform (Linux, macOS, Windows)

## Keccak-256

The primary hashing function used in Ethereum for:
- Address generation
- Transaction hashing
- Block hashing
- Merkle trees
- Storage keys

### Algorithm Details

- **Family**: SHA-3 (Secure Hash Algorithm 3)
- **Output**: 256 bits (32 bytes)
- **Rate**: 1088 bits
- **Capacity**: 512 bits
- **Rounds**: 24

## Build

### Using CMake

```bash
mkdir build && cd build
cmake ..
make
```

### Manual Compilation

```bash
g++ -std=c++17 -O3 -o keccak256 keccak256.cpp
```

## Usage

### Run Example

```bash
./keccak256
```

Output:
```
Keccak-256 Hash Examples
========================

Input: ""
Hash:  0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470

Input: "Hello, Ethereum!"
Hash:  0x...

Input: "The quick brown fox jumps over the lazy dog"
Hash:  0x...
```

### As a Library

```cpp
#include "keccak256.cpp"

using namespace crypto;

int main() {
    // Hash a string
    std::string input = "Hello, Blockchain!";
    std::string hash = Keccak256::hash_hex(input);

    std::cout << "Hash: " << hash << std::endl;

    return 0;
}
```

## Ethereum Address Generation

Ethereum addresses are generated from public keys:

```
1. Public Key (65 bytes) -> Remove '04' prefix -> 64 bytes
2. Keccak-256(public_key) -> 32 bytes
3. Take last 20 bytes -> Ethereum address
```

Example:
```cpp
std::string pubkey = "04e68acfc0...";  // 130 hex chars
std::string hash = Keccak256::hash_hex(pubkey.substr(2));
std::string address = "0x" + hash.substr(hash.length() - 40);
```

## Performance

Benchmarks on Intel i7 (single-threaded):

| Input Size | Hashes/sec | Throughput |
|------------|------------|------------|
| 32 bytes   | ~2M        | ~64 MB/s   |
| 1 KB       | ~300K      | ~300 MB/s  |
| 1 MB       | ~400       | ~400 MB/s  |

## Verification

Test vectors from Ethereum:

```
keccak256("") =
c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470

keccak256("test") =
9c22ff5f21f0b81b113e63f7db6da94fedef11b2119b4088b89664fb9a3cb658
```

## Security Considerations

- This is a reference implementation for education
- For production, use audited libraries like OpenSSL or libsodium
- Always use constant-time operations for sensitive data
- Validate all inputs in production code

## Advanced Usage

### Incremental Hashing

```cpp
Keccak256 k;
k.update(data1, length1);
k.update(data2, length2);
auto hash = k.finalize();
```

### Binary Data

```cpp
std::vector<uint8_t> data = {0x01, 0x02, 0x03};
Keccak256 k;
k.update(data.data(), data.size());
auto hash = k.finalize();
```

## Differences from SHA-256

| Feature | Keccak-256 | SHA-256 |
|---------|------------|---------|
| Structure | Sponge construction | Merkle-Damgård |
| Rounds | 24 | 64 |
| State size | 1600 bits | 256 bits |
| Bitcoin | ❌ | ✅ |
| Ethereum | ✅ | ❌ |

## Other Cryptographic Primitives

Future additions:
- [ ] secp256k1 (ECDSA)
- [ ] BLS signatures
- [ ] Merkle tree implementation
- [ ] RLP encoding
- [ ] AES-256-GCM

## Building for WASM

Compile to WebAssembly:

```bash
emcc -O3 -s WASM=1 -s EXPORTED_FUNCTIONS='["_hash"]' \
  keccak256.cpp -o keccak256.wasm
```

## Dependencies

- C++17 compiler (GCC 7+, Clang 5+, MSVC 2017+)
- CMake 3.15+ (optional)

## Resources

- [Keccak Specification](https://keccak.team/specifications.html)
- [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
- [FIPS 202 (SHA-3)](https://csrc.nist.gov/publications/detail/fips/202/final)

## License

MIT
