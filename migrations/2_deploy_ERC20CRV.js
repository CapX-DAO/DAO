var ERC20CRV = artifacts.require("../ERC20CRV.sol");

module.exports = function (deployer) {
  deployer.deploy(ERC20CRV,"CAPX Token","Capx",18);
};
