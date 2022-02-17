var ERC20CRV = artifacts.require("ERC20CRV");

module.exports = function (deployer) {
  deployer.deploy(ERC20CRV,"Token", "TOK", 18);
};
