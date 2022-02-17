var VotingEscrowDelegation = artifacts.require("VotingEscrowDelegation.sol");
var Utils = artifacts.require("Utils.sol");

module.exports = function(deployer) {
  deployer.deploy(Utils);
  deployer.link(Utils, VotingEscrowDelegation);
  deployer.deploy(VotingEscrowDelegation, "Token", "TOK", "base_uri");
};
