var VotingEscrow = artifacts.require("VotingEscrow");
var ERC20CRV = artifacts.require("ERC20CRV");
module.exports = function (deployer) {
<<<<<<< HEAD
    // need to add the CAPX token smart contract's address as first argument
    // providing a ganache address for now: account no: 4
    //const token_address = 0x8aE52CeF899c28fa04751E37cC4779A79474AC4C;
    
    // deployer.deploy(VotingEscrow, ERC20CRV.address, "CAPX Token", "CAPX", "1.0");
=======

    deployer.deploy(VotingEscrow, ERC20CRV.address, "CAPX Token", "CAPX", "1.0");
>>>>>>> 85717962b005d466f1d65c48f5a29e05f78207be
};
