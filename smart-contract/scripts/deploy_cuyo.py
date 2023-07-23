from brownie import Cuyo, accounts


def deploy_cuyo():
    household_accounts = accounts[1:11]
    
    # Raised to 3
    generation = 2000000            # 2 kW / 2000 W
    storage_capacity = 2000000      # 2 kW / 2000 W
        
    cuyo = accounts[0].deploy(Cuyo, household_accounts, generation, storage_capacity)
    return cuyo

def main():
    deploy_cuyo()