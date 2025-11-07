const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{
        .default_target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
        },
    });

    const optimize = b.standardOptimizeOption(.{});

    // WebAssembly library
    const lib = b.addSharedLibrary(.{
        .name = "crypto",
        .root_source_file = .{ .path = "sha256.zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.rdynamic = true;
    b.installArtifact(lib);

    // Tests
    const tests = b.addTest(.{
        .root_source_file = .{ .path = "sha256.zig" },
        .target = target,
        .optimize = optimize,
    });

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&b.addRunArtifact(tests).step);
}
