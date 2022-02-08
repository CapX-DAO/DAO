const VotingEscrowDelegation = artifacts.require("VotingEscrowDelegation");

module.exports = function (deployer) {
  deployer.deploy(VotingEscrowDelegation, "CAPX Token", "CAPX", "base_uri");
};
