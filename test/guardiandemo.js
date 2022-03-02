const ERC20CRV = artifacts.require('ERC20CRV')
const VotingEscrow = artifacts.require('VotingEscrow')
const GovernanceStrategy = artifacts.require('GovernanceStrategy')
const AaveGovernanceV2 = artifacts.require('AaveGovernanceV2')
const Executor = artifacts.require('Executor')
const Dummy1 = artifacts.require('Dummy1')
const helper = require('../utils')

// the guardian wants to cancel the proposal during the voting period
// after successful cancellation, the proposal cannot be queued and executed. 


contract ('AaveGovernanceV2', ([deployer, guardian_address]) => {

    let token; 
    let escrow;     
    let gstrat;
    let aaveV2;
    let exec;
    let dummy1; 
    let address = deployer;
    let voting_delay = 0
    let guardian_addr = guardian_address
    let executors = [deployer]

    let value = 126144001
    let unlock_time = new Date();
    unlock_time.setDate(unlock_time.getDate() + 100);
    unlock_time = parseInt(unlock_time.getTime() / 1000);


    let admin
    let delay 
    let gracePeriod
    let minimumDelay
    let maximumDelay 
    let propositionThreshold 
    let voteDuration 
    let voteDifferential 
    let minimumQuorum 
    let result 
    
    let targets
    let old_count
    let new_count

    let id
    let voteSubmitted

    describe('guardiandemo', async()=> {

        it('checks if the ERC20CRV contract corectly', async() => {
         token =  await ERC20CRV.new('Token', 'TOK', 18)
            assert(token.address != "", "CRV not deployed correctly")
        })

        it('checks if the Voting Escrow contract has deployed correcly', async() => {
            escrow = await VotingEscrow.new(token.address, 'Token', 'TOK', 18)
            assert(escrow.address != "", "Voting Escrow has not deployed correclty")
        })

        describe('checks the overall integration for testing', async() => {

            it('checks if able to create the lock', async() => {
                await token.approve(escrow.address, value)
                await escrow.create_lock(value, unlock_time)
            })

            it('checks if able to deploy governance strategy', async() => {
                gstrat = await GovernanceStrategy.new(escrow.address)
                assert(gstrat.address != "", 'Governance strategy not deploying correctly')
            })            

            it('checks if the balance of the user from voting escrow and governance strategy are the same', async() => {
                
                let blk_number = await gstrat.get_block_number();
                let balance1, balance2

                balance1 = await gstrat.getVotingPowerAt(address, blk_number.toNumber())
                balance2 = await escrow.balanceOfAt(address, blk_number.toNumber())
                assert(balance1.toNumber() === balance2.toNumber(), "Function is not working correctly")
            })

            it('checks if able to deploy aaveGovernance strategy', async() => {
                aaveV2 = await AaveGovernanceV2.new(gstrat.address, voting_delay, guardian_addr ,executors)
                assert(aaveV2.address != "", "Not able to deploy the AaveGovernanceV2 contract")
            })


            it('checks if able to deploy Executor with given values', async() => {
                admin = aaveV2.address
                delay = 0
                gracePeriod = 300
                minimumDelay = 0
                maximumDelay = 300
                propositionThreshold = 0
                voteDuration = 2
                voteDifferential = 0
                minimumQuorum = 0
                
                 exec = await Executor.new(admin, delay, gracePeriod, minimumDelay, maximumDelay, 
                propositionThreshold, voteDuration, voteDifferential, minimumQuorum)
                assert(exec.address != "", "Not able to deploy the executor contract")
                 
            })
            
            
            it('checks if we are able to authorize the executor', async() => {
                try{
                    await aaveV2.authorizeExecutors([exec.address])
                    assert(true)
                }catch(err){
                    console.err(err)
                    assert(false, "Function should have worked with the given executor address")
                }

                // will return true or false depending on how the function above worked
                result = await aaveV2.isExecutorAuthorized(exec.address)
                assert(result, "The executor is not authorized")    
            })
            
            
            it('checks deployment of dummy contract and tranferring of ownership', async() => {

                // deploying a dummy contract for proposal: 
                // positive test
                dummy1 = await Dummy1.new()
                try{
                    await dummy1.transferOwnership(exec.address)
                    assert(true)
                }catch(err){
                    assert(false, "Function should have worked")
                }

                let add = exec.address
                let new_owner = await dummy1.owner()
                assert(new_owner.toString() == add.toString(), "Executor is not the owner")
            })

            it('creates a new proposal for testing', async() => {
                targets = [dummy1.address] 
                old_count = await aaveV2.getProposalsCount()  
                await aaveV2.create(exec.address, targets, [0],["Setval(uint256)"],["0x0000000000000000000000000000000000000000000000000000000000000005"] , [false] , "0x7465737400000000000000000000000000000000000000000000000000000000")
                new_count = await aaveV2.getProposalsCount()
                assert(new_count.toNumber() - old_count.toNumber() == 1, "Proposal was not created")
            })

            it('trying to submit vote on a proposal and prints the vote', async() => {
                
                // to get the id of the most recent proposal, can use any other id for testing as well
                id = new_count.toNumber() - 1
            
                votesubmitted = true;
                // vote for the proposal    
                // should work for our case, may change to a negative test with wrong values later
                try{
                    await aaveV2.submitVote(id, votesubmitted)
                    assert(true)
                }catch(err){
                    assert(false)
                }

                vote = await aaveV2.getVoteOnProposal(id, deployer)
                // should be true for now
                assert(vote.support, "False")

            })


            //NOW GUARDIAN WANTS TO CANCEL THE PROPOSAL
            it('trying to cancel proposal', async() => {

                // first wrong guardian address: negative test
                try{
                    await aaveV2.cancel(id)
                    assert(false, "Should not have worked because should be guardian address")
                }catch(err){
                    assert(true)
                }

                // correct guardian address: positive test
                try{
                    await aaveV2.cancel(id, {from: guardian_address})
                    assert(true)
                }catch(err){
                    assert(false, "It is the guardian address, should have worked")
                }
            })


            it('queueing failed because proposal has been canceled by guardian ', async() => {
                block_number = await gstrat.get_block_number()
                console.log("Current block number now:", block_number.toNumber())    
                
                // this should fail, negative test
                // increase block number by 1
                try{
                    await aaveV2.queue(id)
                    assert(false, "This should not have worked..something wrong in the function ")
                }catch(err){
                    assert(true)
                }

                // // increases block number by 1 again
                let new_block = await gstrat.get_block_number()
                console.log("New block number is: ", new_block.toNumber())
    

                // will not work because proposal has been canceled
                try{
                    await aaveV2.queue(id)
                    assert(false)
                }catch(err){
                    assert(true, "Something wrong")
                }
            })
            
        })  
    })
})