const VEDelegation = artifacts.require('VotingEscrowDelegation')
// const Delegation = artifacts.require('Delegation')
const VotingEscrow = artifacts.require('VotingEscrow')
const ERC20CRV = artifacts.require('ERC20CRV')
const Utils = artifacts.require('Utils')

contract ('VEDelegation', ([deployer, receiver, delegator]) => {
    const name = "CAPX Token";
    const symbol = "CAPX";

    let vedel;
    let escrow;
    let token;
    let value = 126144001
    let result;
    let id;
    let unlock_time = new Date();
    unlock_time.setDate(unlock_time.getDate() + 100);
    unlock_time = parseInt(unlock_time.getTime() / 1000);

    beforeEach(async() => {
        token = await ERC20CRV.new("CAPX Token", "CAPX", 18);
        escrow = await VotingEscrow.new(token.address, "CAPX Token", "CAPX", "1.0")
        utils = await Utils.new();
        vedel = await VEDelegation.new("CAPX Token", "CAPX", "base_uri", escrow.address, utils.address);
        //Utilsdel = await Utilsdel.new();

    })

    describe('deployment', () => {
        it('checks the name of the token', async () => {
            const result = await vedel.name();
            assert(result === name);
        })
        it('checks the symbol of the token', async () => {
            const result = await vedel.symbol();
            assert(result === symbol);
        })
    })

    describe('transfer ownership', () => {
        it('commits transfer ownership', async () => {
            const admin = await vedel.admin();
            assert(admin.toString() === deployer.toString(), "You are not the admin");
            await vedel.commit_transfer_ownership(receiver)
            const future_admin = await vedel.future_admin();
            assert(future_admin.toString() === receiver.toString(), "You are not the future admin");
        })
        it('acceptss transfer ownership', async () => {
            await vedel.commit_transfer_ownership(deployer)
            const future_admin = await vedel.future_admin();
            
            assert(future_admin.toString() === deployer.toString(), "You are not the future admin");
            await vedel.accept_transfer_ownership()
            const admin = await vedel.admin();
            assert(admin.toString() === future_admin.toString(), "You are not the admin");
        })
    })

    describe('enumeration data', () => {
        it('updates enumeration data if from address is 0', async () => {
            const token_id = await utils.get_token_id(deployer, 0);
            //console.log(token_id.toString())
            await vedel.update_enumeration_data("0x0000000000000000000000000000000000000000", receiver, token_id, 100, 100)

        })
        it('updates enumeration data if to address is 0-negative', async () => {
            const token_id = await utils.get_token_id(deployer, 0);
            //console.log(token_id.toString())
            try{
                await vedel.update_enumeration_data(deployer, "0x0000000000000000000000000000000000000000", token_id, 100, 100)
                assert(false)
            }
            catch(error){
                assert(true)
            }
            

        })
        it('updates enumeration data', async () => {
            const token_id = await utils.get_token_id(deployer, 0);
            //console.log(token_id.toString())
            await vedel.update_enumeration_data(deployer, receiver, token_id, 100, 100)

        })
    })

    describe('boost', () => {
        it('burns boost', async () => {
            const token_id = await utils.get_token_id(deployer, 0);
            await vedel._burn_boost(token_id, deployer, receiver)
        })
        it('transfers boost-negative', async () => {
            //const token_id = await utils.get_token_id(deployer, 0);
            //const result1 = await vedel.get_boost.call(deployer)
            //console.log(result1.toString())
            //await vedel.boost.call(deployer).then(function(result){console.log(result.toString())})
            try{
                await vedel._transfer_boost(deployer, receiver, 10, 10)
                assert(false)
            }
            catch(error){
                assert(true)
            }
            
            
        })
        it('sets delegation status', async () => {
            //const token_id = await utils.get_token_id(deployer, 0);
            await vedel._set_delegation_status(receiver, delegator, true)
        })
        // it('creates boost', async () => { -> to be used from Delegation.sol
        //     const token_id = await utils.get_token_id(deployer, 0);
        //     let cancel_time = await vedel.token_cancel_time.call(token_id);
        //     //console.log(cancel_time.toString())
        //     //cancel_time = cancel_time.toNumber();
        //     // let expire_time = await vedel.token_expiry.call(token_id);
        //     // expire_time = expire_time + 86400*21;
        //     // let expire_time = await token.get_block_timestamp();
        //     // expire_time = expire_time + 86400*7;
        //     // //console.log(expire_time.toString)
        //     // //expire_time = expire_time.toNumber();
        //     // await vedel.create_boost(delegator, receiver, 50, cancel_time, expire_time, 10)
        //     let unlock_time = new Date();
        //     unlock_time.setDate(unlock_time.getDate() + 14);
        //     unlock_time = parseInt(unlock_time.getTime() / 1000);
        //     await vedel.create_boost(
        //         deployer,
        //         receiver,
        //         900,
        //         unlock_time - 86400 * 7,
        //         unlock_time,
        //         12344432
        //       );
        // })
        // it('extends boost', async () => { -> to be used from Delegation.sol
        //     const token_id = await utils.get_token_id(deployer, 0);
        //     // const cancel_time = unlock_time-1000;
        //     // const expire_time = unlock_time-100;
        //     let cancel_time = await vedel.token_cancel_time.call(token_id);
        //     //console.log(cancel_time)
        //     //cancel_time = cancel_time.toNumber();
        //     let expire_time = await vedel.token_expiry.call(token_id);
        //     //expire_time = expire_time.toNumber();
        //     await vedel.extend_boost(token_id, 10, expire_time, cancel_time, receiver)
        // })
        it('returns the adjusted balance', async() => {
            await vedel.adjusted_balance_of(deployer)
        })
        it('returns the boost received', async () => {
            await vedel.received_boost(deployer)
        })
    })

    describe('token', () => {
        it('returns the boost to a token', async () => {
            const token_id = await utils.get_token_id(deployer, 0)
            await vedel.token_boost(token_id)
        })
    })
})