// const VEDelegation = artifacts.require('VotingEscrowDelegation')
// // const Delegation = artifacts.require('Delegation')
// // const VotingEscrow = artifacts.require('VotingEscrow')
// // const ERC20CRV = artifacts.require('ERC20CRV')

// contract ('VEDelegation', ([deployer, delegator, receiver, test_user]) => {
//     let vedel;
//     let escrow;
//     let token;
//     let value = 126144001
//     let result;
//     let id;
//     let unlock_time = new Date();
//     unlock_time.setDate(unlock_time.getDate() + 100);
//     unlock_time = parseInt(unlock_time.getTime() / 1000);

//     beforeEach(async() => {
//         // token = await ERC20CRV.new("CAPX Token", "CAPX", 18);
//         // escrow = await VotingEscrow.new(token.address, "CAPX Token", "CAPX", "1.0")
//         vedel = await VEDelegation.new("CAPX Token", "CAPX", "base_uri");
//     })

//     describe("Check if contract is able to deploy", async() => {
//         assert(vedel.address != "", "Contract has not deployed")
//     })

//     describe("Check if able to create boost", async() => {
//         // await token.approve(escrow.address , 126144001);
//         // await escrow.create_lock(value, unlock_time);
//         id = 10;
//         await vedel.create_boost(delegator, receiver, 20, 16762100, 16762200, 10, {from : delegator})
//     })

//     describe("Functions related to boost", async() => {
//         beforeEach(async() => {
//             // await token.approve(escrow.address , 126144001);
//             // await escrow.create_lock(value, unlock_time);
//             id = 10;
//             await vedel.create_boost(delegator, receiver, 20, 16762100, 16762200, 10, {from : deployer})
//         })

//         // don't know what value of token_id to put
//         it('Extends boost amount', async() => {
//             let token_id = await vedel.get_token_id(delegator, 10);
//             // await vedel.burn(token_id);
//             await vedel.extend_boost(token_id, 50, 16762150, 16762250)
//         })

//         it('Cancels boost that was delegated', async() => {
//             //cancel_boost
//             let token_id = await vedel.get_token_id(delegator, 10)
//             await vedel.cancel_boost(token_id);

//         })

//         it('calculates the adjusted veCRV balance after delegation', async() => {
//             // adjusted_balance_of
//             // can be any address
//             let address = delegator;
//             value = vedel.adjusted_balance_of(delegator)
//             console.log(value);

//         })

//         it('calculates the total delegated boost of an account', async() => {
//             // delegated_boost
//             value = await vedel.delegated_boost(delegator);
//             console.log(value.toString());

//         })

//         it('calculates the total received boost of an account', async() => {
//             // received_boost
//             value = await vedel.received_boost(receiver);
//             console.log(value.toString());
//         })

//         it('calculates the total value of a boost', async() => {
//             // token_boost
//             id = await vedel.get_token_id(delegator, 10);
//             result = await vedel.token_boost(id);
//             console.log(result.toString());
//         })

//         it('calculates the token expiry of a boost', async() => {
//             id = await vedel.get_token_id(delegator, 10);
//             result = await vedel.token_expiry(id);
//             console.log(result.toString());
//         })

//         it('calculates the token cancel time of a boost', async() => {
//             id = await vedel.get_token_id(delegator, 10);
//             result = await vedel.token_cancel_time(id);
//             console.log(result.toString())
//         })

//     })

// })
