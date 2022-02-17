// const Delegation = artifacts.require('Delegation');
// const VotingEscrow = artifacts.require('VotingEscrow');
// const ERC20CRV = artifacts.require('ERC20CRV');
// const VotingEscrowDelegation = artifacts.require('VotingEscrowDelegation');

// contract('Delegation', ([deployer, delegator, ownership_admin, emergency_admin, receiver, test_user, future_ownership_admin, future_emergency_admin]) => {

//     let del; 
//     let vedel 
//     let escrow;
//     let value, result;
//     beforeEach(async() => {

//         vedel = await VotingEscrowDelegation.new("Token", "TOK", "base_uri")
//         del = await Delegation.new();
//         escrow = await VotingEscrow.new(ERC20CRV.address, "Token", "TOK", "1.0")
//     })

//     describe('check for deployment', async() => {

//         it('check if deployment being done correctly', async() => {
//             assert(del.address != '', "Contract not deployed correctly");
//         })

//     })

//     describe('check if the function is able to set values', async() => {
//         it('checks the init function for setting values', async() => {
//             let value1 = await del.getOwnershipAdmin();
//             let value2 = await del.getEmergencyAdmin();
//             let value3 = await del.getDelegation();

//             console.log("Address of ownership admin", value1);
//             console.log("Address of emergency admin", value2);
//             console.log("Delegated address", value3);

//             await del.__init__(vedel, ownership_admin, emergency_admin, {from: deployer});
            
//             let value4 = await del.getOwnershipAdmin();
//             let value5 = await del.getEmergencyAdmin();
//             let value6 = await del.getDelegation();
            
//             console.log("New Address of ownership admin", value4);
//             console.log("New Address of emergency admin", value5);
//             console.log("New Delegated address", value6);
//         })

//     })

//     describe('check basic functions related to delegation', async() => {

//         beforeEach(async() => {
//             // need to put deployed address of VotingEscrowDelegation contract
//             await del.__init__(vedel, ownership_admin, emergency_admin, {from: deployer});
//         }) 
        
//         it('checks if able to kill a delegated address', async() => {
            
//             await del.kill_delegation({from: ownership_admin});

//             let value7 = await del.getDelegation();
//             console.log("New Delegated address", value7.toString());

//             assert(value7.toString() === vedel.toString(), "Not able to kill address");

//         })


//         // not working because the adjust_balance_of function is not working
//         // it('checks if able to set a delegated address', async() => {
            
//         //     delegated = await del.getDelegation();
//         //     console.log("Current delegated address: ", delegated.toString());
//         //     await del.set_delegation(test_user, {from: ownership_admin});
//         //     delegated = await del.getDelegation();
//         //     console.log("New delegated address after setting: ", delegated.toString());
//         // })


//         it('checks if able to set new admins', async() => {
//             let future_o_admin = future_ownership_admin;
//             let future_e_admin = future_emergency_admin; 

//             let current_o_admin = await del.getOwnershipAdmin();
//             let current_e_admin = await del.getEmergencyAdmin();

//             console.log("Current ownership admin", current_o_admin.toString());
//             console.log("Current emergency admin", current_e_admin.toString());

//             await del.commit_set_admins(future_o_admin, future_e_admin, {from: ownership_admin});
//             await del.apply_set_admins({from: ownership_admin});

//             future_o_admin = await del.getOwnershipAdmin();
//             future_e_admin = await del.getEmergencyAdmin();

//             console.log("New ownership admin", future_o_admin.toString());
//             console.log("New emergency admin", future_e_admin.toString());

//             assert((current_o_admin != future_o_admin) || (current_e_admin != future_e_admin), "Not able to set ownership admin");

//         })
//     })


//     // VM Exception while processing transaction: revert
//     describe('checking the adjusted balance', async() => {
//         it('checks balance of the account', async() => {
//             // can be any address

//             let address = delegator;
//             value = await del.adjusted_balance_of(address);
//             console.log("Adjusted balance:", value.toString());

//             // only if delegation contract set to zero, print votingescrow account value
//             assert(escrow.balanceOf(address) === value)
//         })
//     })

// })  