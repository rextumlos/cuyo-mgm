import pytest
from brownie import Cuyo, accounts
from brownie.exceptions import VirtualMachineError


@pytest.fixture()
def cuyo():
    household_accounts = accounts[1:11]
    
    # Raised to 3
    generation = 999999
    storage_capacity = 9999999
        
    cuyo = accounts[0].deploy(Cuyo, household_accounts, generation, storage_capacity)
    return cuyo

def test_init(cuyo):
    cuyo_info = cuyo.get_grid_info.call()
    assert cuyo_info[0] == 999999
    assert cuyo_info[1] == 0
    assert cuyo_info[2] == 9999999
    assert cuyo_info[3] == 0
    assert cuyo_info[4] == 0
    assert len(cuyo_info[5]) == 10
    assert cuyo_info[6] == 0
    
def test_set_a_household_demand(cuyo):
    household_1 = accounts[1]
    expected_demand = 999
    
    with pytest.raises(VirtualMachineError):
        cuyo.set_household_demand(household_1, expected_demand, {"from": accounts[2]})
    
    txn = cuyo.set_household_demand(household_1, expected_demand, {"from": household_1})
    txn.wait(1)
    
    cuyo_info = cuyo.get_grid_info.call()
    
    assert cuyo_info[5][0][1] == expected_demand
  
  
def test_grid_stable(cuyo):
    households = accounts[1:11]
    demand = 1
    for household in households:
        txn = cuyo.set_household_demand(household, demand, {"from": household})
        txn.wait(1)
        
    cuyo_info = cuyo.get_grid_info.call()
    assert cuyo_info[4] == 0        # Stable
        
            
def test_grid_warning(cuyo):
    households = accounts[1:11]
    demand = 100000
    for household in households:
        txn = cuyo.set_household_demand(household, demand, {"from": household})
        txn.wait(1)
        
    cuyo_info = cuyo.get_grid_info.call()
    assert cuyo_info[4] == 1        # Warning
    
def test_grid_unstable(cuyo):
    households = accounts[1:11]
    demand = 1111111
    for household in households:
        txn = cuyo.set_household_demand(household, demand, {"from": household})
        txn.wait(1)
        
    cuyo_info = cuyo.get_grid_info.call()
    assert cuyo_info[4] == 2        # Unstable
    

def test_reset_microgrid(cuyo):
    households = accounts[1:11]
    demand = 1
    for household in households:
        txn = cuyo.set_household_demand(household, demand, {"from": household})
        txn.wait(1)
        
    cuyo_info_initial = cuyo.get_grid_info.call()
    assert cuyo_info_initial[1] == 10
    
    with pytest.raises(VirtualMachineError):
        cuyo.reset_microgrid({"from": accounts[1]})
    
    tx = cuyo.reset_microgrid({"from": accounts[0]})
    tx.wait(1)
    
    cuyo_info = cuyo.get_grid_info.call()
    assert cuyo_info[1] == 0