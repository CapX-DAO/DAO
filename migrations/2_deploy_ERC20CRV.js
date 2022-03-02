var ERC20CRV = artifacts.require("ERC20CRV");

module.exports = async function (deployer) {
  await deployer.deploy(ERC20CRV,"Token", "TOK" , 8);
};
