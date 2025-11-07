#include <iostream>
#include <vector>
#include <cstring>
#include <iomanip>
#include <sstream>

// Keccak-256 implementation for Ethereum
// Based on the SHA-3 standard with Ethereum-specific parameters

namespace crypto {

const uint64_t ROUND_CONSTANTS[24] = {
    0x0000000000000001ULL, 0x0000000000008082ULL, 0x800000000000808aULL,
    0x8000000080008000ULL, 0x000000000000808bULL, 0x0000000080000001ULL,
    0x8000000080008081ULL, 0x8000000000008009ULL, 0x000000000000008aULL,
    0x0000000000000088ULL, 0x0000000080008009ULL, 0x000000008000000aULL,
    0x000000008000808bULL, 0x800000000000008bULL, 0x8000000000008089ULL,
    0x8000000000008003ULL, 0x8000000000008002ULL, 0x8000000000000080ULL,
    0x000000000000800aULL, 0x800000008000000aULL, 0x8000000080008081ULL,
    0x8000000000008080ULL, 0x0000000080000001ULL, 0x8000000080008008ULL
};

const int ROTATION_OFFSETS[24] = {
    1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 2, 14,
    27, 41, 56, 8, 25, 43, 62, 18, 39, 61, 20, 44
};

const int PI_LANE[24] = {
    10, 7, 11, 17, 18, 3, 5, 16, 8, 21, 24, 4,
    15, 23, 19, 13, 12, 2, 20, 14, 22, 9, 6, 1
};

inline uint64_t rotl64(uint64_t x, int n) {
    return (x << n) | (x >> (64 - n));
}

class Keccak256 {
private:
    uint64_t state[25];
    uint8_t buffer[136];  // Rate for Keccak-256
    size_t buffer_size;

    void keccak_round() {
        uint64_t C[5], D[5], B[25];

        // Theta
        for (int x = 0; x < 5; x++) {
            C[x] = state[x] ^ state[x + 5] ^ state[x + 10] ^ state[x + 15] ^ state[x + 20];
        }
        for (int x = 0; x < 5; x++) {
            D[x] = C[(x + 4) % 5] ^ rotl64(C[(x + 1) % 5], 1);
        }
        for (int x = 0; x < 5; x++) {
            for (int y = 0; y < 25; y += 5) {
                state[x + y] ^= D[x];
            }
        }

        // Rho and Pi
        for (int i = 0; i < 24; i++) {
            B[i] = rotl64(state[PI_LANE[i]], ROTATION_OFFSETS[i]);
        }
        B[24] = state[0];

        // Chi
        for (int y = 0; y < 25; y += 5) {
            for (int x = 0; x < 5; x++) {
                state[x + y] = B[x + y] ^ ((~B[((x + 1) % 5) + y]) & B[((x + 2) % 5) + y]);
            }
        }
    }

    void absorb_block() {
        for (size_t i = 0; i < 136; i += 8) {
            uint64_t lane = 0;
            for (int j = 0; j < 8; j++) {
                lane |= static_cast<uint64_t>(buffer[i + j]) << (8 * j);
            }
            state[i / 8] ^= lane;
        }

        for (int round = 0; round < 24; round++) {
            uint64_t C[5], D[5];

            // Theta
            for (int x = 0; x < 5; x++) {
                C[x] = state[x] ^ state[x + 5] ^ state[x + 10] ^ state[x + 15] ^ state[x + 20];
            }
            for (int x = 0; x < 5; x++) {
                D[x] = C[(x + 4) % 5] ^ rotl64(C[(x + 1) % 5], 1);
            }
            for (int i = 0; i < 25; i++) {
                state[i] ^= D[i % 5];
            }

            // Rho and Pi
            uint64_t current = state[1];
            for (int i = 0; i < 24; i++) {
                int j = PI_LANE[i];
                uint64_t temp = state[j];
                state[j] = rotl64(current, ROTATION_OFFSETS[i]);
                current = temp;
            }

            // Chi
            for (int y = 0; y < 25; y += 5) {
                uint64_t temp[5];
                for (int x = 0; x < 5; x++) {
                    temp[x] = state[y + x];
                }
                for (int x = 0; x < 5; x++) {
                    state[y + x] = temp[x] ^ ((~temp[(x + 1) % 5]) & temp[(x + 2) % 5]);
                }
            }

            // Iota
            state[0] ^= ROUND_CONSTANTS[round];
        }
    }

public:
    Keccak256() : buffer_size(0) {
        std::memset(state, 0, sizeof(state));
    }

    void update(const uint8_t* data, size_t length) {
        for (size_t i = 0; i < length; i++) {
            buffer[buffer_size++] = data[i];
            if (buffer_size == 136) {
                absorb_block();
                buffer_size = 0;
            }
        }
    }

    std::vector<uint8_t> finalize() {
        // Padding
        buffer[buffer_size++] = 0x01;
        while (buffer_size < 136) {
            buffer[buffer_size++] = 0x00;
        }
        buffer[135] |= 0x80;

        absorb_block();

        // Extract hash
        std::vector<uint8_t> hash(32);
        for (size_t i = 0; i < 4; i++) {
            for (int j = 0; j < 8; j++) {
                hash[i * 8 + j] = static_cast<uint8_t>(state[i] >> (8 * j));
            }
        }

        return hash;
    }

    static std::string hash_hex(const std::string& input) {
        Keccak256 k;
        k.update(reinterpret_cast<const uint8_t*>(input.c_str()), input.length());
        auto hash = k.finalize();

        std::stringstream ss;
        ss << "0x";
        for (uint8_t byte : hash) {
            ss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(byte);
        }
        return ss.str();
    }
};

} // namespace crypto

int main() {
    using namespace crypto;

    // Test vector from Ethereum
    std::string test1 = "";
    std::string test2 = "Hello, Ethereum!";
    std::string test3 = "The quick brown fox jumps over the lazy dog";

    std::cout << "Keccak-256 Hash Examples\n";
    std::cout << "========================\n\n";

    std::cout << "Input: \"" << test1 << "\"\n";
    std::cout << "Hash:  " << Keccak256::hash_hex(test1) << "\n\n";

    std::cout << "Input: \"" << test2 << "\"\n";
    std::cout << "Hash:  " << Keccak256::hash_hex(test2) << "\n\n";

    std::cout << "Input: \"" << test3 << "\"\n";
    std::cout << "Hash:  " << Keccak256::hash_hex(test3) << "\n\n";

    // Demonstrate Ethereum address generation
    std::string pubkey = "0x04e68acfc0253a10620dff706b0a1b1f1f5833ea3beb3bde2250d5f271f3563606672ebc45e0b7ea2e816ecb70ca03137b1c9476eec63d4632e990020b7b6fba39";
    std::cout << "Ethereum Address Generation Demo:\n";
    std::cout << "Public Key: " << pubkey << "\n";
    std::cout << "Keccak-256: " << Keccak256::hash_hex(pubkey.substr(2)) << "\n";
    std::cout << "(Last 20 bytes = Ethereum address)\n";

    return 0;
}
