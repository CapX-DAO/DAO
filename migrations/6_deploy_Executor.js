var Executor = artifacts.require("Executor")
var AaveGovernanceV2 = artifacts.require("AaveGovernanceV2")

let execution_delay = 0
let gracePeriod = 750
let minimumDelay = 0
let maximumDelay = 750
let propositionThreshold = 2000
let voteDuration = 5
let voteDifferential = 500
let minimumQuorum = 2000

module.exports = async function(deployer) {
    
    let AaveGovernanceinstance = await AaveGovernanceV2.deployed()

    await deployer.deploy(Executor, AaveGovernanceinstance.address, execution_delay, gracePeriod, minimumDelay, maximumDelay, 
        propositionThreshold, voteDuration, voteDifferential, minimumQuorum);
};
