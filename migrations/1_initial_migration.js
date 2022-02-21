const Migrations = artifacts.require("Migrations");
var VotingEscrowDelegation = artifacts.require("../VotingEscrowDelegation.sol");
var Utils = artifacts.require(
  "../dependencies/openzeppelin-solidity/Utils.sol"
);
var ERC20CRV = artifacts.require("../ERC20CRV.sol");
var VotingEscrow = artifacts.require("../VotingEscrow.sol");
var Delegations = artifacts.require("../Delegation.sol");

module.exports = async function(deployer) {
  const accounts = await web3.eth.getAccounts();
  await console.log("Deploying using : ", accounts[0]);
  await deployer.deploy(Migrations);
  let utilsinstance = await deployer.deploy(Utils);
  await console.log(utilsinstance.address);
  let tokeninstance = await deployer.deploy(ERC20CRV, "CAPX Token", "CAPX", 18);
  await console.log(tokeninstance.address);
  let escrowinstance = await deployer.deploy(
    VotingEscrow,
    tokeninstance.address,
    "veToken",
    "ve",
    "1.0"
  );
  await console.log(escrowinstance.address);
  let vedinstance = await deployer.deploy(
    VotingEscrowDelegation,
    "veToken",
    "ve",
    "base_uri",
    escrowinstance.address,
    utilsinstance.address
  );
  await console.log(vedinstance.address);
  let delegationinstance = await deployer.deploy(
    Delegations,
    vedinstance.address,
    accounts[0],
    accounts[0],
    "base_uri",
    escrowinstance.address,
    utilsinstance.address
  );
  await console.log(delegationinstance.address);

  // deployer.deploy(Utils).then(function() {
  //   deployer.link(Utils, VotingEscrowDelegation);
  //   deployer.link(Utils, Delegations);
  //   deployer.deploy(ERC20CRV, "CAPX Token", "CAPX", 18).then(function() {
  //     deployer
  //       .deploy(VotingEscrow, ERC20CRV.address, "CAPX Token", "CAPX", "1.0")
  //       .then(function() {
  //         deployer
  //           .deploy(
  //             VotingEscrowDelegation,
  //             "CAPX Token",
  //             "CAPX",
  //             "base_uri",
  //             VotingEscrow.address
  //           )
  //           .then(function() {
  //             deployer.deploy(
  //               Delegations,
  //               VotingEscrowDelegation.address,
  //               deployer,
  //               deployer,
  //               "base_uri",
  //               VotingEscrow.address
  //             );
  //           });
  //       });
  //   });
  // });

  // deployer.link(Delegations, VotingEscrowDelegation);
};
