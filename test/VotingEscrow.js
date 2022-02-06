const Votingescrow = artifacts.require("VotingEscrow");
const ERC20CRV = artifacts.require("ERC20CRV");

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

        it('test to create a lock', async() => {
            
            // before creating the lock
            balance = await escrow.balanceOf(address);
            

            // creating a lock
            await token.approve(escrow.address , value);
            await escrow.create_lock(value, unlock_time);

            // after creating the lock
            const balance1 = await escrow.balanceOf(address);
            
            assert(balance.toNumber() != balance1.toNumber(), "Function not working");
        })
    })


    describe('testing different functions after creating lock', async() => {

        beforeEach(async() => {

            await token.approve(escrow.address , value);
            await escrow.create_lock(value, unlock_time);
        })

        // throwing gas consumption error
        it('increase the amount to be locked', async() => {
            balance = await escrow.balanceOf(address);
            await token.approve(escrow.address , value);
            value = 126144001;
            await escrow.increase_amount(value);
            balance1 = await escrow.balanceOf(address);
            
            assert(balance1.toNumber() != balance.toNumber(), "Function not working")
        })

        it('increase the unlock time', async() => {
            const current_end = await escrow.locked__end(address);
            
            unlock_time = 1676242000;
            await escrow.increase_unlock_time(unlock_time);
            const next_end = await escrow.locked__end(address);
            
        })            

        it('gets the voting power at an epoch', async() => {
            let epoch_time = new Date();
            epoch_time.setDate(epoch_time.getDate() + 1);
            epoch_time = epoch_time.getTime() / 1000;
            const addr = deployer;
            result = await escrow.getVotingPowerAt(addr, unlock_time);
            
        })
        
        it('gets the voting power of the msg.sender', async() => {
            let voting_power = await escrow.balanceOf(address,unlock_time, {from: deployer});
            
        })

        it('gets the voting power at a block height', async() => {
            let block_number = await escrow.get_block_number();
            
            const block_height = block_number.toNumber();
            result = await escrow.balanceOfAt(address, block_height);
            
            assert(parseInt(result.toString()) != 0, "Function not working");
        })
        
        it('checks if user is able to withdraw the locked tokens', async() => {
            
            // will throw an error if unlock time not over yet
            try {
                await escrow.withdraw()
                assert(false, "Function not working");
            }
            catch (err){
                console.error('error')
                console.error(err);
                assert(true, "Function not working");
            }
        })
        
        // throws error: header not found
        it('calculates the total voting power at an epoch time', async() => {
            epoch_time = 1646241122
            result = await escrow.totalSupply(epoch_time);
            
            assert.isNumber(result); 
        })
        
        it('calculates the total voting power at a block in the past', async() => {
            let block_number = await escrow.get_block_number();
            
            const block_height = block_number.toNumber();
            result = await escrow.totalSupplyAt(block_height);
            
            assert(parseInt(result.toString()) != 0, "Function not working");
        })
    })
})