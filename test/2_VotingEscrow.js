const VotingEscrow = artifacts.require("VotingEscrow");
const ERC20CRV = artifacts.require("ERC20CRV");

contract ('VotingEscrow', ([deployer, receiver, sender, checker, testUser]) => {
    let escrow;
    let token;
    let address = deployer;
    let value = 126144001;
    let unlockTime = new Date();
    unlockTime.setDate(unlockTime.getDate() + 100);
    unlockTime = parseInt(unlockTime.getTime() / 1000);

    let balance
    let result

    beforeEach(async() => {
        token = await ERC20CRV.new("Token", "TOK", 18);
        escrow = await VotingEscrow.new(token.address, "Token", "TOK", "1.0");

    })

    describe('deployment checks for voting escrow', async () => {

        it('Should deploy the smart contract properly', async() => {
            assert(escrow.address !== '', "Has not deployed correctly");
        })
    })


    describe('transfership tests', async() => {
        
        it('checks if admin can transfer ownership', async() => {

            const futureAdmin = sender;
            let currentAdmin = await escrow.getAdmin();
            
            await escrow.commitTransferOwnership(futureAdmin, {from : deployer});

            currentAdmin = await escrow.getAdmin();
            

            await escrow.applyTransferOwnership({from: deployer});
            currentAdmin = await escrow.getAdmin();

            
            assert(currentAdmin.toString() === futureAdmin, "Function not working");
        })
    })    
        

    describe('smart wallet checker tests', async() => {
        it('checks if admin can apply smart wallet checker', async() => {
            
            const smartWalletCheckerAddress = checker;
            let currentChecker = await escrow.getSmartWalletChecker();
            
            await escrow.commitSmartWalletChecker(smartWalletCheckerAddress, {from : deployer});

            currentChecker = await escrow.getSmartWalletChecker();
            

            await escrow.applySmartWalletChecker({from: deployer});
            currentChecker = await escrow.getSmartWalletChecker();

            
            assert(currentChecker.toString() === smartWalletCheckerAddress.toString(), "Function not working");
        })
    })


    describe('creating lock', async() => {

        it('test to create a lock', async() => {
            
            // before creating the lock
            balance = await escrow.balanceOf(address);
            

            // creating a lock
            await token.approve(escrow.address , value);
            await escrow.createLock(value, unlockTime);

            // after creating the lock
            const balance1 = await escrow.balanceOf(address);
            
            assert(balance.toNumber() != balance1.toNumber(), "Function not working");
        })
    })


    describe('testing different functions after creating lock', async() => {

        beforeEach(async() => {

            await token.approve(escrow.address , value);
            await escrow.createLock(value, unlockTime);
        })

        // throwing gas consumption error
        it('increase the amount to be locked', async() => {
            balance = await escrow.balanceOf(address);
            await token.approve(escrow.address , value);
            value = 126144001;
            await escrow.increaseAmount(value);
            balance1 = await escrow.balanceOf(address);
            
            assert(balance1.toNumber() != balance.toNumber(), "Function not working")
        })

        it('increase the unlock time', async() => {
            const currentEnd = await escrow.lockedEnd(address);
            
            unlockTime = 1676242000;
            await escrow.increaseUnlockTime(unlockTime);
            const next_end = await escrow.lockedEnd(address);
            
        })            

        it('gets the voting power at an epoch', async() => {
            let epochTime = new Date();
            epochTime.setDate(epochTime.getDate() + 1);
            epochTime = epochTime.getTime() / 1000;
            const addr = deployer;
            result = await escrow.getVotingPowerAt(addr, unlockTime);
            
        })
        
        it('gets the voting power of the msg.sender', async() => {
            let votingPower = await escrow.balanceOf(address,unlockTime, {from: deployer});
            
        })

        it('gets the voting power at a block height', async() => {
            let blockNumber = await escrow.getBlockNumber();
            
            const blockHeight = blockNumber.toNumber();
            result = await escrow.balanceOfAt(address, blockHeight);
            
            assert(parseInt(result.toString()) != 0, "Function not working");
        })
        
        it('checks if user is able to withdraw the locked tokens', async() => {
            
            // will throw an error if unlock time not over yet
            try {
                await escrow.withdraw()
                assert(false, "Function not working");
            }
            catch (err){
                assert(true, "Function not working");
            }
        })
        
        it('calculates the total voting power at an epoch time', async() => {
            epochTime = 1646241122
            result = await escrow.totalSupplyAtEpoch(epochTime);
            
            assert.isNumber(result.toNumber()); 
        })
        
        it('calculates the total voting power at a block in the past', async() => {
            let blockNumber = await escrow.getBlockNumber();
            
            const blockHeight = blockNumber.toNumber();
            result = await escrow.totalSupplyAt(blockHeight);
            
            assert(parseInt(result.toString()) != 0, "Function not working");
        })
    })
})