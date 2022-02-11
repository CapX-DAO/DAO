const ERC20CRV = artifacts.require('ERC20CRV');
const helper = require('../utils');

contract ('ERC20CRV', ([deployer, receiver, sender, mintreceiver, minter]) => {

    let token;
    
    const name = "CAPX Token";
    const symbol = "CAPX";
    const decimals = "18"

    beforeEach(async() => {
        token = await ERC20CRV.new("CAPX Token", "CAPX", 18);
    })

    describe('deployment checks for ERC20CRV', () => {

        it('Should deploy the smart contract properly', async() => {
            assert(token.address !== '');
        })

        it('Check the name of the token', async() => {
            const result = await token.name();
            assert(result === name);
        })

        it('Check the symbol of the token', async() => {
            const result = await token.symbol();
            assert(result === symbol);
        })

        it('Check the decimals', async() => {
            const result = await token.decimals();
            assert(result.toString() === decimals);
        })

        it('Check the total supply', async() => {
            const result = await token.totalSupply();
            assert(result.toNumber() === 1303030303);
        })

        it('Check the balance of any user', async() => {
            const result = await token.balanceOf(deployer);
            assert(result.toString() === "1303030303");
        })

    })

        
 
    describe('total Supply', () => {
        it('Checking current supply at and minting', async() => {
            let result;
            result = await token.totalSupplyAt(0);

            result = await token.mint(mintreceiver, 100);
            result = await token.totalSupplyAt(0)
            const result1 = await token.totalSupply()
            assert(result.toNumber() != result1.toNumber && result1.toNumber() - result.toNumber() == 100)
        })

        it('checks the amount of tokens that an owner is allowed to a spender', async() => {
            // allowance() function
            await token.approve(receiver, 20 ,{from : deployer});
            const result = await token.allowance(deployer, receiver);

            assert(result.toNumber() == 20, "Function is not working correctly");
        })
    });

    describe('mining parameters', () => {
        let result
        let timestamp
        let rate
        let start_epoch_supply
        
        it('emits an UpdateMiningParameters event', async () => {
            advancement = 86400 * 730 // 2 year 
            await helper.advanceTimeAndBlock(advancement);

            result = await token.update_mining_parameters()
            timestamp = await token.get_block_timestamp()
            rate = await token.rate()
            start_epoch_supply = await token.start_epoch_supply()
            
            const log = result.logs[0]
            console.log(log.event)
            assert(log.event.toString() === 'UpdateMiningParameters')
            const event = log.args
            assert(event.time.toString() == timestamp.toString())
            assert(event.rate.toString() == rate.toString())
            assert(event.supply.toString() == start_epoch_supply.toString())
        })
    })

    describe('epoch time', () => {
        it('returns start_epoch_time', async () => {
            result = await token.start_epoch_time_write.call()
            start_epoch_time = await token.start_epoch_time()
            
            assert(result.toString() == start_epoch_time.toString())
            
        })

        it('emits an UpdateMiningParameters event from start_epoch_time_write', async () => {
            advancement = 86400 * 730 // 2 year 
            await helper.advanceTimeAndBlock(advancement);

            result = await token.start_epoch_time_write()
            timestamp = await token.get_block_timestamp()
            rate = await token.rate()
            start_epoch_supply = await token.start_epoch_supply()
            
            const log = result.logs[0]
            console.log(log.event)
            assert(log.event.toString() === 'UpdateMiningParameters')
            const event = log.args
            assert(event.time.toString() == timestamp.toString())
            assert(event.rate.toString() == rate.toString())
            assert(event.supply.toString() == start_epoch_supply.toString())
        })

        it('returns future_epoch_time', async () => {
            result = await token.future_epoch_time_write.call()
            future_epoch_time = await token.start_epoch_time()
            future_epoch_time = future_epoch_time.toNumber()
            future_epoch_time += 86400*365

            assert(result.toString() == future_epoch_time.toString())
            
        })

        it('emits an UpdateMiningParameters event from future_epoch_time_write', async () => {
            advancement = 86400 * 730 // 2 year 
            await helper.advanceTimeAndBlock(advancement);

            result = await token.future_epoch_time_write()
            timestamp = await token.get_block_timestamp()
            rate = await token.rate()
            start_epoch_supply = await token.start_epoch_supply()
            
            const log = result.logs[0]
            console.log(log.event)
            assert(log.event.toString() === 'UpdateMiningParameters')
            const event = log.args
            assert(event.time.toString() == timestamp.toString())
            assert(event.rate.toString() == rate.toString())
            assert(event.supply.toString() == start_epoch_supply.toString())
        })
    })


    describe('tests related to transfer', () => {
        it('checks if user can transfer token to another user', async() => {
            
            let balanceOf 

            // before transfer
            balanceOf = await token.balanceOf(deployer);
            balanceOf = await token.balanceOf(receiver);

            const value = await token.allowance(deployer, receiver);


            await token.approve(receiver, 100, { from: deployer });
            // transfer
            await token.transfer(receiver, 10, { from: deployer });

            // after transfer
            balanceOf = await token.balanceOf(deployer);
            balanceOf = await token.balanceOf(receiver);

        })


        it('checks if transfer from one account to another', async() => {


            // before transferFrom()
            let balance1 = await token.balanceOf(deployer);
            let balance2 = await token.balanceOf(receiver);
            await token.approve(sender, 100, {from : deployer});
            let value_to_send = 20;
            // transfer
            const result = await token.transferFrom(deployer, receiver, value_to_send ,{from : sender});

            // after transferFrom()
            balance3 = await token.balanceOf(deployer);
            balance4 = await token.balanceOf(receiver);


            assert(balance1.toNumber() - balance3.toNumber() == value_to_send && balance4.toNumber() - balance2.toNumber() == value_to_send , "Did not pass the test case");
        })

    
        it('check if approve spender to transfer tokens on behalf of a user', async() => {
            // approve function
            const spender_address = sender;
            const value = 10;
            const balance1 = await token.balanceOf(sender);
            const balance2 = await token.balanceOf(deployer);


            const result = await token.approve(spender_address, value, {from : deployer});
            const balance3 = await token.balanceOf(sender);
            const balance4 = await token.balanceOf(deployer);
        })
    })
        


    describe('burn tokens', async() => {
        it('check if able to burn tokens', async() => {

            let currentTotalSupply
            currentTotalSupply = await token.totalSupply();
            const result = await token.burn(3);
            const newCurrentTotalSupply = await token.totalSupply();
            assert(newCurrentTotalSupply <= currentTotalSupply);
        })
    })

    describe('Set minter', async() => {
        it('checks that the minter is only set once', async() => {
            const admin = await token.get_admin();
            assert(admin.toString() === deployer.toString(), "You are not the admin");
            const current_minter = await token.get_minter();
            //console.log(current_minter)
            assert(current_minter.toString() === '0x0000000000000000000000000000000000000000', "Minter can only be set once");
            await token.set_minter(minter);
            let new_minter = await token.get_minter();
            assert(new_minter.toString() === minter.toString(), "Function not working correctly");
        })
    })
        

    describe('Check if admin is able to set a new admin', async() => {
        it('if the user is the admin', async() => {

            // getting the admin address: 
            const admin = await token.get_admin();
            assert(admin.toString() === deployer.toString(), "You are not the admin");
            await token.set_admin(sender);
            let new_admin = await token.get_admin();
            assert(new_admin.toString() === sender.toString(), "Function not working correctly");
        })
    })


    describe('Check if the admin is able to set a new name and symbol of the token', async() => {
        it('if it is the admin', async() => {
            const token_name = "Hello"
            const symbol = "HELL"
            const current_admin = await token.get_admin();
            await token.set_name(token_name, symbol);
            let new_token = await token.name();
            let new_symbol = await token.symbol();
            assert(new_token.toString() === token_name.toString());
            assert(new_symbol.toString() === symbol.toString());
        })

    })

})

