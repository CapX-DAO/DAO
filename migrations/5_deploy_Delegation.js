let VotingEscrow = artifacts.require("../VotingEscrow.sol");
let ERC20CRV = artifacts.require("../ERC20CRV.sol");
let Delegation = artifacts.require("../Delegation.sol");


module.exports = function (deployer) {

    deployer.deploy(Delegation);
};
