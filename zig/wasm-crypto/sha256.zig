const std = @import("std");

/// SHA-256 implementation optimized for WebAssembly
/// Designed for blockchain hash operations
pub const Sha256 = struct {
    const Self = @This();
    const block_size = 64;
    const digest_size = 32;

    h: [8]u32,
    buffer: [block_size]u8,
    total_len: u64,
    buffer_len: usize,

    const k = [64]u32{
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
        0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
        0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
        0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
        0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
        0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
        0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
        0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
    };

    pub fn init() Self {
        return Self{
            .h = [8]u32{
                0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
                0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
            },
            .buffer = undefined,
            .total_len = 0,
            .buffer_len = 0,
        };
    }

    inline fn rotr(x: u32, n: u5) u32 {
        return (x >> n) | (x << (32 - n));
    }

    fn processBlock(self: *Self, block: *const [64]u8) void {
        var w: [64]u32 = undefined;

        // Prepare message schedule
        var i: usize = 0;
        while (i < 16) : (i += 1) {
            w[i] = (@as(u32, block[i * 4 + 0]) << 24) |
                (@as(u32, block[i * 4 + 1]) << 16) |
                (@as(u32, block[i * 4 + 2]) << 8) |
                (@as(u32, block[i * 4 + 3]));
        }

        i = 16;
        while (i < 64) : (i += 1) {
            const s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >> 3);
            const s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16] +% s0 +% w[i - 7] +% s1;
        }

        // Working variables
        var a = self.h[0];
        var b = self.h[1];
        var c = self.h[2];
        var d = self.h[3];
        var e = self.h[4];
        var f = self.h[5];
        var g = self.h[6];
        var h = self.h[7];

        // Main loop
        i = 0;
        while (i < 64) : (i += 1) {
            const S1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
            const ch = (e & f) ^ (~e & g);
            const temp1 = h +% S1 +% ch +% k[i] +% w[i];
            const S0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
            const maj = (a & b) ^ (a & c) ^ (b & c);
            const temp2 = S0 +% maj;

            h = g;
            g = f;
            f = e;
            e = d +% temp1;
            d = c;
            c = b;
            b = a;
            a = temp1 +% temp2;
        }

        // Add to hash
        self.h[0] +%= a;
        self.h[1] +%= b;
        self.h[2] +%= c;
        self.h[3] +%= d;
        self.h[4] +%= e;
        self.h[5] +%= f;
        self.h[6] +%= g;
        self.h[7] +%= h;
    }

    pub fn update(self: *Self, data: []const u8) void {
        var offset: usize = 0;

        while (offset < data.len) {
            const available = block_size - self.buffer_len;
            const to_copy = @min(available, data.len - offset);

            @memcpy(self.buffer[self.buffer_len..][0..to_copy], data[offset..][0..to_copy]);
            self.buffer_len += to_copy;
            offset += to_copy;

            if (self.buffer_len == block_size) {
                self.processBlock(&self.buffer);
                self.total_len += block_size;
                self.buffer_len = 0;
            }
        }
    }

    pub fn final(self: *Self, out: *[digest_size]u8) void {
        const total_bits = (self.total_len + self.buffer_len) * 8;

        // Padding
        self.buffer[self.buffer_len] = 0x80;
        self.buffer_len += 1;

        if (self.buffer_len > 56) {
            @memset(self.buffer[self.buffer_len..], 0);
            self.processBlock(&self.buffer);
            self.buffer_len = 0;
        }

        @memset(self.buffer[self.buffer_len..56], 0);

        // Append length
        var i: usize = 0;
        while (i < 8) : (i += 1) {
            self.buffer[63 - i] = @intCast(u8, (total_bits >> (@intCast(u6, i * 8))) & 0xff);
        }

        self.processBlock(&self.buffer);

        // Output hash
        i = 0;
        while (i < 8) : (i += 1) {
            out[i * 4 + 0] = @intCast(u8, (self.h[i] >> 24) & 0xff);
            out[i * 4 + 1] = @intCast(u8, (self.h[i] >> 16) & 0xff);
            out[i * 4 + 2] = @intCast(u8, (self.h[i] >> 8) & 0xff);
            out[i * 4 + 3] = @intCast(u8, self.h[i] & 0xff);
        }
    }
};

// WebAssembly exports
export fn hash(input_ptr: [*]const u8, input_len: usize, output_ptr: [*]u8) void {
    var hasher = Sha256.init();
    hasher.update(input_ptr[0..input_len]);
    var output: [32]u8 = undefined;
    hasher.final(&output);
    @memcpy(output_ptr[0..32], &output);
}

// Test
test "SHA-256 basic" {
    const input = "hello world";
    var hasher = Sha256.init();
    hasher.update(input);

    var output: [32]u8 = undefined;
    hasher.final(&output);

    // Expected: b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
    const expected = [_]u8{
        0xb9, 0x4d, 0x27, 0xb9, 0x93, 0x4d, 0x3e, 0x08,
        0xa5, 0x2e, 0x52, 0xd7, 0xda, 0x7d, 0xab, 0xfa,
        0xc4, 0x84, 0xef, 0xe3, 0x7a, 0x53, 0x80, 0xee,
        0x90, 0x88, 0xf7, 0xac, 0xe2, 0xef, 0xcd, 0xe9,
    };

    try std.testing.expectEqualSlices(u8, &expected, &output);
}
