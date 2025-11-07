cmake_minimum_required(VERSION 3.15)
project(CryptoAlgorithms VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Compiler flags
if(MSVC)
    add_compile_options(/W4)
else()
    add_compile_options(-Wall -Wextra -Wpedantic -O3)
endif()

# Keccak-256 executable
add_executable(keccak256 keccak256.cpp)

# Installation
install(TARGETS keccak256 DESTINATION bin)

# Tests (optional)
enable_testing()
add_test(NAME keccak256_test COMMAND keccak256)
