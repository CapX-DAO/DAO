const ERC20CRV = artifacts.require('ERC20CRV')
const VotingEscrow = artifacts.require('VotingEscrow')
const GovernanceStrategy = artifacts.require('GovernanceStrategy')
const AaveGovernanceV2 = artifacts.require('AaveGovernanceV2')
const Executor = artifacts.require('Executor')
const Dummy1 = artifacts.require('Dummy1')

let unlock_time = new Date();
    unlock_time.setDate(unlock_time.getDate() + 100);
    unlock_time = parseInt(unlock_time.getTime() / 1000);

module.exports = async function(deployer) {

    const accounts = await web3.eth.getAccounts();
    await console.log(accounts)

    await console.log("Address of deployer:", accounts[0])
    let ERCinstance = await ERC20CRV.deployed()

    let voter1 = accounts[1]
    let voter2 = accounts[2]


    let VotingEscrowinstance = await VotingEscrow.deployed()
    let GovernanceStrategyinstance = await GovernanceStrategy.deployed()
    let AaveGovernanceV2instance = await AaveGovernanceV2.deployed()
    let Executorinstance = await Executor.deployed()
    let Dummy1instance = await Dummy1.deployed()

    await console.log("ERC address: ", ERCinstance.address)
    await console.log("Voting Escrow address: ", VotingEscrowinstance.address)
    await console.log("Governance strategy address: ", GovernanceStrategyinstance.address)
    await console.log("Aave governance address: ", AaveGovernanceV2instance.address)
    await console.log("Executor address: ", Executorinstance.address)
    await console.log("Dummy1 address: ", Dummy1instance.address)


    let result = await Dummy1instance.getval()
    await console.log("The initial value is: ", result.toNumber())

    const value1 = 500000000
    const value2 = 1000000000

    await console.log("voter1 account: ", voter1)
    await console.log("voter2 account: ", voter2)

    // await ERCinstance.mint(accounts[1], value1)
    // await ERCinstance.mint(accounts[2], value2)
    // await console.log("after mint")


    // await ERCinstance.approve(VotingEscrowinstance.address, value)
    // await ERCinstance.approve(VotingEscrowinstance.address, value1, {from: voter1})
    // await ERCinstance.approve(VotingEscrowinstance.address, value2, {from: voter2})
    await console.log("after approve")

    // already done in the deployment
    // await VotingEscrowinstance.create_lock(value1 unlock_time)
    // await VotingEscrowinstance.create_lock(value1, unlock_time, {from: voter1})
    // await VotingEscrowinstance.create_lock(value2, unlock_time, {from: voter2})

    // locks for the account have already been created in the Rinkeby network
    blk_number = await GovernanceStrategyinstance.get_block_number()
    await console.log("created lock")
    
    result = await VotingEscrowinstance.balanceOfAt(accounts[0], blk_number.toNumber())
    await console.log("Voting power deployer: ", result.toNumber())
    result = await VotingEscrowinstance.balanceOfAt(accounts[1], blk_number.toNumber())
    await console.log("Voting power voter1: ", result.toNumber())
    result = await VotingEscrowinstance.balanceOfAt(accounts[2], blk_number.toNumber())
    await console.log("Voting power voter2: ", result.toNumber())

    result = await VotingEscrowinstance.totalSupply()
    await console.log("Total voting power: ", result.toNumber())

    await AaveGovernanceV2instance.authorizeExecutors([Executorinstance.address])

    await console.log("authorize")

    // already done in the deployment
    // await Dummy1instance.transferOwnership(Executorinstance.address)

    await console.log("transfer")
}