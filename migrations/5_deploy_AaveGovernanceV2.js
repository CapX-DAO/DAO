var AaveGovernanceV2 = artifacts.require("AaveGovernanceV2")
var GovernanceStrategy = artifacts.require("GovernanceStrategy")

let voting_delay = 0
// need to pass addresses
let guardian_addr
let executors = ["0x0000000000000000000000000000000000000000"]

module.exports = async function(deployer) {
    
    const accounts = await web3.eth.getAccounts();
    await console.log(accounts)
    // need to pass 


    await deployer.deploy(AaveGovernanceV2, GovernanceStrategy.address, voting_delay, accounts[0], executors);
};
