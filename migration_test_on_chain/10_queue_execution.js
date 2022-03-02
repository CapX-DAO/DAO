// this is a continuation of the demo.js file
// when the block number in Rinkeby has increased by 5, the proposal should get queued for execution


const AaveGovernanceV2 = artifacts.require('AaveGovernanceV2')
const Dummy1 = artifacts.require('Dummy1')

module.exports = async function(deployer) {

    let AaveGovernanceV2instance = await AaveGovernanceV2.deployed()
    let Dummy1instance = await Dummy1.deployed()

    await console.log("deployed")

    let proposal_count = await AaveGovernanceV2instance.getProposalsCount()

    await console.log("proposal count")
    let id = proposal_count.toNumber() - 1

    await AaveGovernanceV2instance.queue(id)

    await console.log("proposal queueud")
    await AaveGovernanceV2instance.execute(id)

    await console.log("executed")
    result = await Dummy1instance.getval()
    await console.log("The final value after execution is: ", result.toNumber())

}