var AaveGovernanceV2 = artifacts.require("AaveGovernanceV2")
var GovernanceStrategy = artifacts.require("GovernanceStrategy")

let votingDelay = 0
// need to pass addresses
let guardianAddr
let executors = ["0x0000000000000000000000000000000000000000"]

module.exports = async function(deployer) {
    
    const accounts = await web3.eth.getAccounts();
    await console.log(accounts)
    // need to pass 


    await deployer.deploy(AaveGovernanceV2, GovernanceStrategy.address, votingDelay, accounts[0], executors);
};
