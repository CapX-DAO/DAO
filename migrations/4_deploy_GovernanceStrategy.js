var VotingEscrow = artifacts.require("VotingEscrow");
var GovernanceStrategy = artifacts.require("GovernanceStrategy")

module.exports = async function(deployer) {
    
    // const accounts = await web3.eth.getAccounts();
    let VotingEscrowInstance = await VotingEscrow.deployed()
    // await console.log(accounts)
    await deployer.deploy(GovernanceStrategy, VotingEscrowInstance.address);
};
