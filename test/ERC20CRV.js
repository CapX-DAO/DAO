const ERC20CRV = artifacts.require('ERC20CRV');

contract ('ERC20CRV', ([deployer, receiver, sender, mintreceiver]) => {

    let token;
    
    const name = "CAPX Token";
    const symbol = "CAPX";
    const decimals = "18"

    beforeEach(async() => {
        token = await ERC20CRV.new("CAPX Token", "CAPX", 18);
    })

    describe('deployment checks for ERC20CRV', () => {

        it('Should deploy the smart contract properly', async() => {
            console.log(token.address);
            assert(token.address !== '');
        })

        it('Check the name of the token', async() => {
            const result = await token.name();
            console.log(result);
            assert(result === "CAPX Token");
        })

        it('Check the symbol of the token', async() => {
            const result = await token.symbol();
            console.log(result);
            assert(result === "CAPX");
        })

        it('Check the decimals', async() => {
            const result = await token.decimals();
            console.log(result.toNumber());
            assert(result.toNumber() === 18);
        })

        it('Check the total supply', async() => {
            const result = await token.totalSupply();
            console.log(result.toNumber());
            assert(result.toNumber() === 1303030303);
        })

        it('Check the balance of any user', async() => {
            const result = await token.balanceOf(deployer);
            console.log("The balance of the given user is: ", result.toString());
            assert(result.toString() === "1303030303");
        })

    })

        
 
    describe('total Supply', () => {
        it('Checking current supply at and minting', async() => {
            let result;
            result = await token.totalSupplyAt(0);
            console.log("The total Supply at the block number 0 is", result.toNumber());
            result = await token.mint(mintreceiver, 100);
            result = await token.totalSupplyAt(0)
            const result1 = await token.totalSupply()
            assert(result.toNumber() != result1.toNumber && result1.toNumber() - result.toNumber() == 100)
        })
    });


        // working 
        it('checks the amount of tokens that an owner is allowed to a spender', async() => {
            // allowance() function
            await token.approve(receiver, 20 ,{from : deployer});
            const result = await token.allowance(deployer, receiver);
            console.log("The amount that the owner is allowed to a spender is", result.toString());
            assert(result.toNumber() == 20, "Function is not working correctly");
        })



    describe('tests related to transfer', () => {
        it('checks if user can transfer token to another user', async() => {
            
            let balanceOf 

            // before transfer
            balanceOf = await token.balanceOf(deployer);
            console.log("deployer balance before transfer", balanceOf.toString());
            balanceOf = await token.balanceOf(receiver);
            console.log("receiver balance before transfer", balanceOf.toString());

            const value = await token.allowance(deployer, receiver);
            console.log("The value is :", value.toString());

            await token.approve(receiver, 100, { from: deployer });
            // transfer
            await token.transfer(receiver, 10, { from: deployer });

            // after transfer
            balanceOf = await token.balanceOf(deployer);
            console.log("deployer balance after transfer", balanceOf.toString());
            balanceOf = await token.balanceOf(receiver);
            console.log("receiver balance after transfer", balanceOf.toString());
        })


        it('checks if transfer from one account to another', async() => {
            // transferFrom() function

            // before transferFrom()
            let balance1 = await token.balanceOf(deployer);
            console.log("deployer balance before from transfer", balance1.toString())
            let balance2 = await token.balanceOf(receiver);
            console.log("receiver balance before transfer", balance2.toString())

            await token.approve(sender, 100, {from : deployer});
            let value_to_send = 20;
            // transfer
            const result = await token.transferFrom(deployer, receiver, value_to_send ,{from : sender});

            // after transferFrom()
            balance3 = await token.balanceOf(deployer);
            console.log("deployer balance after transfer", balance3.toString());
            balance4 = await token.balanceOf(receiver);
            console.log("receiver balance after transfer", balance4.toString());

            assert(balance1.toNumber() - balance3.toNumber() == value_to_send && balance4.toNumber() - balance2.toNumber() == value_to_send , "Did not pass the test case");
        })

    
        it('check if approve spender to transfer tokens on behalf of a user', async() => {
            // approve function
            const spender_address = sender;
            const value = 10;
            const balance1 = await token.balanceOf(sender);
            const balance2 = await token.balanceOf(deployer);

            console.log("Deployer amount before approve: ", balance2.toString());
            const result = await token.approve(spender_address, value, {from : deployer});
            const balance3 = await token.balanceOf(sender);
            const balance4 = await token.balanceOf(deployer);
            console.log("Deployer amount after approve: ", balance4.toString());

            console.log("Allowed:", result);
        })


    })
        


    describe('burn tokens', async() => {
        it('check if able to burn tokens', async() => {
            // burn() function
            let currentTotalSupply
            currentTotalSupply = await token.totalSupply();
            console.log("Before burning, the total supply is:", currentTotalSupply.toString());
            const result = await token.burn(3);
            const newCurrentTotalSupply = await token.totalSupply();
            console.log("After burning, the totla supply is:", newCurrentTotalSupply.toString());

            assert(newCurrentTotalSupply <= currentTotalSupply);
        })
    })
        

    describe('Check if admin is able to set a new admin', async() => {
        it('if the user is the admin', async() => {

            // getting the admin address: 
            const admin = await token.get_admin();
            console.log("The current admin is: ", admin);

            assert(admin.toString() === deployer.toString(), "You are not the admin");
            await token.set_admin(sender);
            console.log("The address to put as new admin is", sender);

            let new_admin = await token.get_admin();
            console.log("The new admin is:", new_admin);

            assert(new_admin.toString() === sender.toString(), "Function not working correctly");
        })
    })


    describe('Check if the admin is able to set a new name and symbol of the token', async() => {
        it('if it is the admin', async() => {
            const token_name = "Hello"
            const symbol = "HELL"

            const current_admin = await token.get_admin();
            console.log("The current admin is: ", current_admin)

            await token.set_name(token_name, symbol);

            let new_token = await token.name();
            let new_symbol = await token.symbol();

            console.log("The new token name is: ", new_token);
            console.log("The new symbol name is: ", new_symbol);

            assert(new_token.toString() === token_name.toString());
            assert(new_symbol.toString() === symbol.toString());
        })

    })

})

