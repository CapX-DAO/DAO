var VotingEscrow = artifacts.require("VotingEscrow");
var ERC20CRV = artifacts.require("ERC20CRV");
module.exports = function (deployer) {

    deployer.deploy(VotingEscrow, ERC20CRV.address, "Token", "TOK", "1.0");
};
