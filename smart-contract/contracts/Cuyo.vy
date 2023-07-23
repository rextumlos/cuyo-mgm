# @version ^0.3

# Development of Blockchain-based Energy Management in Cuyo Island, Palawan; A simulation using Ganache
# Number of households (10 maximum for ganache)
households: address[10]

# Admin address
admin: address

# Grid's energy generation_capacity
generation_capacity: uint256
energy_consumed: uint256

# External storage for excess energy
storage_capacity: uint256
stored_energy_consumed: uint256
excess_energy_added: uint256

# Household's consumption (per certain hours)
struct Transaction:
    fromAddress: address            # Household's address
    demand: uint256                 # Energy demand

transactions: Transaction[10]      # Storing 10 transactions from 10 users
total_transactions: uint256

# Grid stability, 0 - stable | 1 - warning | 2 - unstable
is_grid_stable: uint256

struct Test:
    transactions: Transaction[10]
    energy_consumed: uint256
    stored_energy_consumed: uint256
    excess_energy_added: uint256
    is_grid_stable: uint256

total_tests: uint256
tests: Test[10]


@external
def __init__(households: address[10], generation: uint256, storage_capacity: uint256):

    for household in households:
        assert household != 0x0000000000000000000000000000000000000000, "Should be 10 households."

    self.households = households
    self.generation_capacity = generation
    self.energy_consumed = 0
    self.storage_capacity = storage_capacity
    self.stored_energy_consumed = 0
    self.is_grid_stable = 0
    self.total_transactions = 0
    self.total_tests = 0
    self.admin = msg.sender


@external
def get_grid_info() -> (uint256, uint256, uint256, uint256, uint256, Transaction[10], uint256):
    return self.generation_capacity, self.energy_consumed, self.storage_capacity, self.stored_energy_consumed, self.is_grid_stable, self.transactions, self.total_transactions

@external
def get_tests() -> Test[10]:
    return self.tests

@external
def update_generation(new_generation: uint256):
    assert msg.sender == self.admin, "Invalid access"

    self.generation_capacity = new_generation

@external
def update_storage_capacity(new_storage: uint256):
    assert msg.sender == self.admin, "Invalid access"

    self.storage_capacity = new_storage

@external
def set_household_demand(household: address, demand: uint256):
    assert household in self.households, "Household address not found."
    assert msg.sender == household, "Invalid access."
    for transaction in self.transactions:
        assert not transaction.fromAddress == household, "Household already has input data."

    self.transactions[self.total_transactions] = Transaction({
        fromAddress: household,
        demand: demand
    })

    self.total_transactions += 1
    self.energy_consumed += demand

    # Must only update when all households input their demands
    if self.total_transactions == 10:
        if self.energy_consumed > self.generation_capacity:
            self.stored_energy_consumed = self.energy_consumed - self.generation_capacity
            if self.stored_energy_consumed > self.storage_capacity:
                self.is_grid_stable = 2     # Unstable
            else:
                self.is_grid_stable = 1     # Warning
        elif self.energy_consumed < self.generation_capacity:
            self.excess_energy_added = self.generation_capacity - self.energy_consumed


@external
def reset_microgrid():
    assert msg.sender == self.admin, "Invalid access"
    assert self.total_transactions == 10, "Must all households submitted demand."

    self.tests[self.total_tests] = Test({
        transactions: self.transactions,
        energy_consumed: self.energy_consumed,
        stored_energy_consumed: self.stored_energy_consumed,
        excess_energy_added: self.excess_energy_added,
        is_grid_stable: self.is_grid_stable
    })

    self.total_tests += 1

    # Reset transactions
    for i in range(10):
        self.transactions[i] = Transaction({fromAddress: (0x0000000000000000000000000000000000000000), demand: 0})
    
    self.energy_consumed = 0
    self.stored_energy_consumed = 0
    self.excess_energy_added = 0
    self.is_grid_stable = 0
    self.total_transactions = 0
    