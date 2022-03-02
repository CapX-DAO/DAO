var Dummy1 = artifacts.require("Dummy1");

module.exports = async function (deployer) {
  await deployer.deploy(Dummy1);
};
