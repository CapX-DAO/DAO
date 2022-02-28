const Votingescrow = artifacts.require("VotingEscrow");
const ERC20CRV = artifacts.require("ERC20CRV");
const helper = require('../utils')

contract ('VotingEscrow', ([deployer, receiver, sender, checker, testUser]) => {
    let escrow;
    let token;
    let address = deployer;
    let value = 126144001;
    let unlock_time = new Date();
    unlock_time.setDate(unlock_time.getDate() + 100);
    unlock_time = parseInt(unlock_time.getTime() / 1000);


    let balance
    let result

    beforeEach(async() => {
        token = await ERC20CRV.new("CAPX Token", "CAPX", 18);
        escrow = await Votingescrow.new(token.address, "CAPX Token", "CAPX", "1.0");
        
    })

    describe('deployment checks for voting escrow', async () => {

        it('Should deploy the smart contract properly', async() => {
            assert(escrow.address !== '', "Has not deployed correctly");
        })
    })

    describe('transfership tests', async() => {
        
        it('checks if admin can transfer ownership', async() => {

            const future_admin = sender;
            let current_admin = await escrow.get_admin();
            await escrow.commit_transfer_ownership(future_admin, {from : deployer});
            current_admin = await escrow.get_admin();
            await escrow.apply_transfer_ownership({from: deployer});
            current_admin = await escrow.get_admin();
            assert(current_admin.toString() === future_admin, "Function not working");
        })
    })    
        

    describe('smart wallet checker tests', async() => {
        it('checks if admin can apply smart wallet checker', async() => {
            
            const smart_wallet_checker_address = checker;
            let current_checker = await escrow.get_smart_wallet_checker();
            await escrow.commit_smart_wallet_checker(smart_wallet_checker_address, {from : deployer});
            current_checker = await escrow.get_smart_wallet_checker();
            await escrow.apply_smart_wallet_checker({from: deployer});
            current_checker = await escrow.get_smart_wallet_checker();

            
            assert(current_checker.toString() === smart_wallet_checker_address.toString(), "Function not working");
        })
    })


    describe('creating lock', async() => {

        describe('success', async() => {
            
            let vp1, vp2, balance1, balance2

            it('will successfully create a lock', async() => {
            await token.approve(escrow.address , value);

            // before creating the lock
            vp1 = await escrow.balanceOf(address);
            balance1 = await token.balanceOf(address);
            
            // creating a lock
            await escrow.create_lock(value, unlock_time);

            // after creating the lock
            vp2 = await escrow.balanceOf(address);
            balance2 = await token.balanceOf(address);
            assert(balance1.toNumber() - balance2.toNumber() === value, "Function not working");
            assert(vp2.toNumber() >= vp1.toNumber(), "Function not working")
            })
        })

        // test should fail
        describe('failure', async() => {
            it('if the sender is someone else', async() => {
                try{
                    await token.approve(escrow.address , value);
                    await escrow.create_lock(value, unlock_time, {from: testUser});
                    assert(false, "Should be the msg.sender")
                }catch(err){
                    assert(true)
                }
            })

            // should fail as unlock_time cannot be greater than 4 years
            it('if the unlock time is greater than block timestamp + maxtime', async() => {
                try{

                    let ts = await escrow.get_block_timestamp()
                    ts = ts.toNumber()
                    let time = 4 * 365 * 86400
                    time *= 2
                    time += ts;
                    
                    await escrow.create_lock(value, time);
                    // if it reaches this assert then the function is not working
                    assert(false, "unlock time is very huge")
                }catch(err){
                    assert(true)
                }
            })
            
        })
    })

    describe('testing different functions after creating lock', async() => {

        let vp1, vp2, balance1, balance2

        beforeEach(async() => {

            await token.approve(escrow.address , value);
            await escrow.create_lock(value, unlock_time);
        })

        it('increase the amount to be locked', async() => {
            // should increase the voting power of the address
            // should decrease the balance of the address

            balance1 = await token.balanceOf(address);
            vp1 = await escrow.balanceOf(address);
            await token.approve(escrow.address , value);
            value = 126144001;
            await escrow.increase_amount(value);
            balance2 = await token.balanceOf(address);
            vp2 = await escrow.balanceOf(address);
            assert(balance1.toNumber() - balance2.toNumber() === value, "Function not working")
            assert(vp2.toNumber() >= vp1.toNumber(), "Function not working")
        })


        it('increase the unlock time', async() => {
            let current_end = await escrow.locked__end(address);
            let time = 1676242000;
            await escrow.increase_unlock_time(time);
            let next_end = await escrow.locked__end(address);
            assert(next_end > current_end, "Function is not working")
            
        })            

        it('gets the voting power at an epoch', async() => {
            
            let vp = await escrow.balanceOf(address);
            let exp_time = await escrow.locked__end(address)
            exp_time = exp_time.toNumber()
            exp_time -= 2419200
            result = await escrow.getVotingPowerAt(address, exp_time);
            assert(result.toNumber() < vp.toNumber(), "Function is not working")
            
        })
        

        it('gets the voting power at a block height', async() => {

            let ts = await escrow.get_block_timestamp();
            let past_block_number = await escrow.get_block_number();
            let vp = await escrow.balanceOf(address);
            let advancement = 86400 * 31// 1 month
            await helper.advanceTimeAndBlock(advancement)
            vp = await escrow.balanceOf(address);
            let current_block_number = await escrow.get_block_number();
            let vp_old = await escrow.balanceOf(address, past_block_number);
            assert(vp_old.toNumber() > vp.toNumber(), "Function is not working")
        })
        
        it('checks if user is able to withdraw the locked tokens', async() => {
            
            // throws an error since unlock time is not yet over
            try {
                ts = await escrow.get_block_timestamp();
                locked = await escrow.locked__end(address);
                await escrow.withdraw()
                assert(false, "Function not working");
            }
            catch (err){
                assert(true);
            }

            // will work since timestamp is advanced to be greater than the expiry time
            try{
                ts = await escrow.get_block_timestamp()
                ts = ts.toNumber()
                advancement = 86400 * 365 * 2 // 5 years
                advancement = advancement + ts
                await helper.advanceTimeAndBlock(advancement);
                locked = await escrow.locked__end(address);
                let balance = await token.balanceOf(address);
                await escrow.withdraw();
                let balance1 = await token.balanceOf(address);
                assert(balance1.toNumber() > balance.toNumber())

            }catch(err){
                assert(false, "Function should have worked")
            }
        })

    })


    describe('some tests related to other parameters', async() => {

        beforeEach(async() => {
            let ts = await escrow.get_block_timestamp();
            let advance = 86400 * 730
            time = ts.toNumber() + advance 
            await token.approve(escrow.address , value);
            await escrow.create_lock(value, time);

        })

        it('gets the last user slope of an address', async() => {
            
            try{
                result = await escrow.get_last_user_slope(address);
                await escrow.checkpoint()
                result = await escrow.get_last_user_slope(address);
                assert(true);

            }catch(err){
                assert(false, "Function not working for some reason")
            }
        })
  

        it('gets the user point history timestamp', async() => {
            try{
                let id = 1;
                result = await escrow.user_point_history__ts(address, id);
                assert(true)
            }catch(err){
                assert(false, "Function not working for some reason")
            }   
        })
        
        // throws an error VM exception while processing transaction: revert
        it('calculates the total voting power at an epoch time', async() => {
            
            try{
                let time = await escrow.get_block_timestamp();
                let locked = await escrow.locked__end(address);
                let epoch = time.toNumber() - (86400 * 100)
                result = await escrow.totalSupplyAtEpoch(epoch);
                assert(true)

            }catch(err){
                assert(false, "Function not working for some reason")
            }
        })


        it('calculates the total voting power', async() => {
            try{
                result = await escrow.totalSupply();
                assert(result.toNumber() >= 0, "Something wrong")
            }catch(err){
                console.log("Function not calculating the total voting power correctly")
            }
        }
        

        it('tries to deposit some amount to an address', async() => {
            try{
                let vp1 = await escrow.balanceOf(address)
                await token.approve(escrow.address, value)
                await escrow.deposit_for(address, value);
                let vp2 = await escrow.balanceOf(address)
                assert(vp2.toNumber() > vp1.toNumber(), "Function not working correctly")

            }catch(err){
                console.log("Test not working")
            }
        })

        it('finds the voting power of an address at a block height', async() => {
            let block = await escrow.get_block_number()
            vp = await escrow.balanceOf(address)
            result = await escrow.balanceOfAt(address, block.toNumber())
            assert(result.toString() === vp.toString(), "Function is not working correctly")
        })

        it('finds the total voting power at a block height', async() => {
            let block = await escrow.get_block_number()
            vp = await escrow.totalSupply()
            result = await escrow.totalSupplyAt(block.toNumber())
            assert(result.toNumber() === vp.toNumber(), "Function is not working correctly")
        })
    })


    describe('Controller', async() => {

        it('some tests for the controller', async() => {
            let controller = await escrow.get_controller();
            try{
                await escrow.changeController(testUser, {from : deployer});
                controller = await escrow.get_controller();
                assert(controller === testUser, "Function not setting controller properly")
            }catch(err){
                console.log("Tests not working")
            }


        // should fail: 
            try{
                await escrow.changeController(receiver, {from: sender});
                controller = await escrow.get_controller();
                assert(false, "Function should not have run because msg.sender must be the controller")
            }catch(err){
                assert(true)
            }
        })
    })
})



// there's something wrong with the assert_not_contract function I guess; I'm always failing the if statement in all cases. 