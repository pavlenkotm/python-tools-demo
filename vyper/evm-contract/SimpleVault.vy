# @version ^0.3.9
"""
@title SimpleVault
@notice A simple vault contract for depositing and withdrawing ETH
@dev Demonstrates Vyper's Pythonic syntax for EVM development
"""

# Events
event Deposit:
    sender: indexed(address)
    amount: uint256
    timestamp: uint256

event Withdrawal:
    recipient: indexed(address)
    amount: uint256
    timestamp: uint256

# Storage
balances: public(HashMap[address, uint256])
owner: public(address)
total_deposited: public(uint256)
is_paused: public(bool)

@external
def __init__():
    """
    @notice Contract constructor
    @dev Sets the deployer as owner
    """
    self.owner = msg.sender
    self.is_paused = False
    self.total_deposited = 0

@external
@payable
def deposit():
    """
    @notice Deposit ETH into the vault
    @dev Emits Deposit event
    """
    assert not self.is_paused, "Contract is paused"
    assert msg.value > 0, "Must send ETH"

    self.balances[msg.sender] += msg.value
    self.total_deposited += msg.value

    log Deposit(msg.sender, msg.value, block.timestamp)

@external
def withdraw(amount: uint256):
    """
    @notice Withdraw ETH from the vault
    @param amount Amount of ETH to withdraw in wei
    @dev Emits Withdrawal event
    """
    assert not self.is_paused, "Contract is paused"
    assert amount > 0, "Amount must be positive"
    assert self.balances[msg.sender] >= amount, "Insufficient balance"

    self.balances[msg.sender] -= amount
    self.total_deposited -= amount

    send(msg.sender, amount)

    log Withdrawal(msg.sender, amount, block.timestamp)

@external
@view
def get_balance(account: address) -> uint256:
    """
    @notice Get the balance of an account
    @param account The address to check
    @return The balance in wei
    """
    return self.balances[account]

@external
@view
def get_contract_balance() -> uint256:
    """
    @notice Get the total ETH held in the contract
    @return The contract balance in wei
    """
    return self.balance

@external
def pause():
    """
    @notice Pause the contract (owner only)
    @dev Prevents deposits and withdrawals
    """
    assert msg.sender == self.owner, "Only owner can pause"
    self.is_paused = True

@external
def unpause():
    """
    @notice Unpause the contract (owner only)
    @dev Allows deposits and withdrawals
    """
    assert msg.sender == self.owner, "Only owner can unpause"
    self.is_paused = False

@external
def transfer_ownership(new_owner: address):
    """
    @notice Transfer ownership to a new address
    @param new_owner The address of the new owner
    @dev Only callable by current owner
    """
    assert msg.sender == self.owner, "Only owner can transfer"
    assert new_owner != empty(address), "Invalid new owner"
    self.owner = new_owner

@external
@view
def get_user_deposit_percentage(account: address) -> uint256:
    """
    @notice Calculate user's deposit as percentage of total
    @param account The address to check
    @return Percentage (basis points, 10000 = 100%)
    """
    if self.total_deposited == 0:
        return 0

    return (self.balances[account] * 10000) / self.total_deposited
