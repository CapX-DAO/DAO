var VotingEscrow = artifacts.require("VotingEscrow");
var ERC20CRV = artifacts.require("ERC20CRV");

module.exports = async function(deployer) {

    let ERCinstance = await ERC20CRV.deployed()
    await console.log(ERCinstance.address)
    await deployer.deploy(VotingEscrow, ERCinstance.address, "Token", "TOK", "1.0");
};
