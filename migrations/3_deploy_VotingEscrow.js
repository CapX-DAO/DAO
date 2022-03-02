var VotingEscrow = artifacts.require("VotingEscrow");
var ERC20CRV = artifacts.require("ERC20CRV");

module.exports = async function(deployer) {

    let ERCInstance = await ERC20CRV.deployed()
    await console.log(ERCInstance.address)
    await deployer.deploy(VotingEscrow, ERCInstance.address, "Token", "TOK", "1.0");
};
