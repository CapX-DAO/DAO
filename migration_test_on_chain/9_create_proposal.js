const ERC20CRV = artifacts.require('ERC20CRV')
const VotingEscrow = artifacts.require('VotingEscrow')
const GovernanceStrategy = artifacts.require('GovernanceStrategy')
const AaveGovernanceV2 = artifacts.require('AaveGovernanceV2')
const Executor = artifacts.require('Executor')
const Dummy1 = artifacts.require('Dummy1')


module.exports = async function(deployer) {
    const accounts = await web3.eth.getAccounts();
    let AaveGovernanceV2Instance = await AaveGovernanceV2.deployed()
    let Dummy1Instance = await Dummy1.deployed()
    let ExecutorInstance = await Executor.deployed()
    let GovernanceStrategyInstance = await GovernanceStrategy.deployed()

    // it won't pass since proposition threshold is 20%
    let targets = [Dummy1Instance.address]
    let voter1 = accounts[1]
    let voter2 = accounts[2]

    // await AaveGovernanceV2Instance.create(ExecutorInstance.address, targets, [0],["setVal(uint256)"],["0x0000000000000000000000000000000000000000000000000000000000000005"] , [false] , "0x7465737400000000000000000000000000000000000000000000000000000000")
    // sets the value to 16
    await AaveGovernanceV2Instance.create(ExecutorInstance.address, targets, [0],["setVal(uint256)"],["0x0000000000000000000000000000000000000000000000000000000000000010"] , [false] , "0x7465737400000000000000000000000000000000000000000000000000000000", {from: voter2})

    await console.log("proposal created")

    let blockNumber = await GovernanceStrategyInstance.getBlockNumber()
    await console.log(" initial block number", blockNumber.toNumber())

    let proposal_count = await AaveGovernanceV2Instance.getProposalsCount()
    let id = proposal_count.toNumber() - 1
    

    // won't queue
    // await AaveGovernanceV2Instance.submitVote(id, true)
    // await AaveGovernanceV2Instance.submitVote(id, true, {from: voter1})
    await AaveGovernanceV2Instance.submitVote(id, true, {from: voter2})


    await console.log("vote submitted")
}