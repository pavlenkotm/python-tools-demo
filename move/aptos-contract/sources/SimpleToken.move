module aptos_token::simple_token {
    use std::signer;
    use std::string::{Self, String};
    use aptos_framework::coin::{Self, Coin};
    use aptos_framework::account;

    /// Error codes
    const E_NOT_OWNER: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    const E_ALREADY_INITIALIZED: u64 = 3;

    /// Token metadata struct
    struct SimpleToken has key {
        name: String,
        symbol: String,
        decimals: u8,
        total_supply: u64,
    }

    /// Account balance resource
    struct Balance has key {
        value: u64,
    }

    /// Initialize the token
    public entry fun initialize(
        account: &signer,
        name: vector<u8>,
        symbol: vector<u8>,
        decimals: u8,
        initial_supply: u64
    ) {
        let account_addr = signer::address_of(account);

        // Ensure not already initialized
        assert!(!exists<SimpleToken>(account_addr), E_ALREADY_INITIALIZED);

        // Create token metadata
        move_to(account, SimpleToken {
            name: string::utf8(name),
            symbol: string::utf8(symbol),
            decimals,
            total_supply: initial_supply,
        });

        // Initialize creator's balance
        move_to(account, Balance {
            value: initial_supply,
        });
    }

    /// Transfer tokens between accounts
    public entry fun transfer(
        from: &signer,
        to_addr: address,
        amount: u64
    ) acquires Balance {
        let from_addr = signer::address_of(from);

        // Ensure sender has balance resource
        assert!(exists<Balance>(from_addr), E_INSUFFICIENT_BALANCE);

        let from_balance = borrow_global_mut<Balance>(from_addr);
        assert!(from_balance.value >= amount, E_INSUFFICIENT_BALANCE);

        // Deduct from sender
        from_balance.value = from_balance.value - amount;

        // Add to receiver (or initialize if first time)
        if (!exists<Balance>(to_addr)) {
            let to_signer = account::create_signer_with_capability(
                &account::create_test_signer_cap(to_addr)
            );
            move_to(&to_signer, Balance { value: amount });
        } else {
            let to_balance = borrow_global_mut<Balance>(to_addr);
            to_balance.value = to_balance.value + amount;
        };
    }

    /// Get balance of an account
    #[view]
    public fun balance_of(addr: address): u64 acquires Balance {
        if (!exists<Balance>(addr)) {
            return 0
        };
        borrow_global<Balance>(addr).value
    }

    /// Get token name
    #[view]
    public fun name(token_addr: address): String acquires SimpleToken {
        borrow_global<SimpleToken>(token_addr).name
    }

    /// Get token symbol
    #[view]
    public fun symbol(token_addr: address): String acquires SimpleToken {
        borrow_global<SimpleToken>(token_addr).symbol
    }

    /// Get total supply
    #[view]
    public fun total_supply(token_addr: address): u64 acquires SimpleToken {
        borrow_global<SimpleToken>(token_addr).total_supply
    }

    /// Mint new tokens (only token owner)
    public entry fun mint(
        owner: &signer,
        to_addr: address,
        amount: u64
    ) acquires SimpleToken, Balance {
        let owner_addr = signer::address_of(owner);

        // Update total supply
        let token = borrow_global_mut<SimpleToken>(owner_addr);
        token.total_supply = token.total_supply + amount;

        // Add to recipient
        if (!exists<Balance>(to_addr)) {
            let to_signer = account::create_signer_with_capability(
                &account::create_test_signer_cap(to_addr)
            );
            move_to(&to_signer, Balance { value: amount });
        } else {
            let balance = borrow_global_mut<Balance>(to_addr);
            balance.value = balance.value + amount;
        };
    }

    /// Burn tokens from sender
    public entry fun burn(
        account: &signer,
        amount: u64
    ) acquires SimpleToken, Balance {
        let addr = signer::address_of(account);

        let balance = borrow_global_mut<Balance>(addr);
        assert!(balance.value >= amount, E_INSUFFICIENT_BALANCE);

        // Decrease balance
        balance.value = balance.value - amount;

        // Decrease total supply
        let token = borrow_global_mut<SimpleToken>(addr);
        token.total_supply = token.total_supply - amount;
    }

    #[test(account = @0x1)]
    public fun test_initialize(account: signer) {
        initialize(
            &account,
            b"Test Token",
            b"TEST",
            8,
            1000000
        );

        let addr = signer::address_of(&account);
        assert!(name(addr) == string::utf8(b"Test Token"), 0);
        assert!(symbol(addr) == string::utf8(b"TEST"), 0);
        assert!(total_supply(addr) == 1000000, 0);
        assert!(balance_of(addr) == 1000000, 0);
    }

    #[test(from = @0x1, to = @0x2)]
    public fun test_transfer(from: signer, to: signer) acquires Balance {
        initialize(
            &from,
            b"Test Token",
            b"TEST",
            8,
            1000000
        );

        let to_addr = signer::address_of(&to);
        transfer(&from, to_addr, 100);

        assert!(balance_of(signer::address_of(&from)) == 999900, 0);
        assert!(balance_of(to_addr) == 100, 0);
    }
}
