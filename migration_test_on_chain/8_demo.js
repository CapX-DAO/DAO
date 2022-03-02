const ERC20CRV = artifacts.require('ERC20CRV')
const VotingEscrow = artifacts.require('VotingEscrow')
const GovernanceStrategy = artifacts.require('GovernanceStrategy')
const AaveGovernanceV2 = artifacts.require('AaveGovernanceV2')
const Executor = artifacts.require('Executor')
const Dummy1 = artifacts.require('Dummy1')

let unlockTime = new Date();
    unlockTime.setDate(unlockTime.getDate() + 100);
    unlockTime = parseInt(unlockTime.getTime() / 1000);

module.exports = async function(deployer) {

    const accounts = await web3.eth.getAccounts();
    await console.log(accounts)

    await console.log("Address of deployer:", accounts[0])
    let ERCInstance = await ERC20CRV.deployed()

    let voter1 = accounts[1]
    let voter2 = accounts[2]


    let VotingEscrowInstance = await VotingEscrow.deployed()
    let GovernanceStrategyInstance = await GovernanceStrategy.deployed()
    let AaveGovernanceV2Instance = await AaveGovernanceV2.deployed()
    let ExecutorInstance = await Executor.deployed()
    let Dummy1Instance = await Dummy1.deployed()

    await console.log("ERC address: ", ERCInstance.address)
    await console.log("Voting Escrow address: ", VotingEscrowInstance.address)
    await console.log("Governance strategy address: ", GovernanceStrategyInstance.address)
    await console.log("Aave governance address: ", AaveGovernanceV2Instance.address)
    await console.log("Executor address: ", ExecutorInstance.address)
    await console.log("Dummy1 address: ", Dummy1Instance.address)


    let result = await Dummy1Instance.getVal()
    await console.log("The initial value is: ", result.toNumber())

    const value1 = 500000000
    const value2 = 1000000000

    await console.log("voter1 account: ", voter1)
    await console.log("voter2 account: ", voter2)

    // await ERCInstance.mint(accounts[1], value1)
    // await ERCInstance.mint(accounts[2], value2)
    // await console.log("after mint")


    // await ERCInstance.approve(VotingEscrowInstance.address, value)
    // await ERCInstance.approve(VotingEscrowInstance.address, value1, {from: voter1})
    // await ERCInstance.approve(VotingEscrowInstance.address, value2, {from: voter2})
    await console.log("after approve")

    // already done in the deployment
    // await VotingEscrowInstance.createLock(value1 unlockTime)
    // await VotingEscrowInstance.createLock(value1, unlockTime, {from: voter1})
    // await VotingEscrowInstance.createLock(value2, unlockTime, {from: voter2})

    // locks for the account have already been created in the Rinkeby network
    blkNumber = await GovernanceStrategyInstance.getBlockNumber()
    await console.log("created lock")
    
    result = await VotingEscrowInstance.balanceOfAt(accounts[0], blkNumber.toNumber())
    await console.log("Voting power deployer: ", result.toNumber())
    result = await VotingEscrowInstance.balanceOfAt(accounts[1], blkNumber.toNumber())
    await console.log("Voting power voter1: ", result.toNumber())
    result = await VotingEscrowInstance.balanceOfAt(accounts[2], blkNumber.toNumber())
    await console.log("Voting power voter2: ", result.toNumber())

    result = await VotingEscrowInstance.totalSupply()
    await console.log("Total voting power: ", result.toNumber())

    await AaveGovernanceV2Instance.authorizeExecutors([ExecutorInstance.address])

    await console.log("authorize")

    // already done in the deployment
    // await Dummy1Instance.transferOwnership(ExecutorInstance.address)

    await console.log("transfer")
}