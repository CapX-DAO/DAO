const VEDelegation = artifacts.require('VotingEscrowDelegation')
// const Delegation = artifacts.require('Delegation')
// const VotingEscrow = artifacts.require('VotingEscrow')
// const ERC20CRV = artifacts.require('ERC20CRV')

contract ('VEDelegation', ([deployer, delegator, receiver]) => {
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
        // token = await ERC20CRV.new("CAPX Token", "CAPX", 18);
        // escrow = await VotingEscrow.new(token.address, "CAPX Token", "CAPX", "1.0")
        vedel = await VEDelegation.new("CAPX Token", "CAPX", "base_uri");
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


})
