import { utils } from 'ethers';
import { getDb, DRE, waitForTx } from './misc-utils';
import { verifyContract } from './etherscan-verification';
export const registerContractInJsonDb = async (contractId, contractInstance) => {
    const currentNetwork = DRE.network.name;
    if (currentNetwork !== 'hardhat' && !currentNetwork.includes('coverage')) {
        console.log(`*** ${contractId} ***\n`);
        console.log(`Network: ${currentNetwork}`);
        console.log(`tx: ${contractInstance.deployTransaction.hash}`);
        console.log(`contract address: ${contractInstance.address}`);
        console.log(`deployer address: ${contractInstance.deployTransaction.from}`);
        console.log(`gas price: ${contractInstance.deployTransaction.gasPrice}`);
        console.log(`gas used: ${contractInstance.deployTransaction.gasLimit}`);
        console.log(`\n******`);
        console.log();
    }
    await getDb()
        .set(`${contractId}.${currentNetwork}`, {
        address: contractInstance.address,
        deployer: contractInstance.deployTransaction.from,
    })
        .write();
};
export const insertContractAddressInDb = async (id, address) => await getDb()
    .set(`${id}.${DRE.network.name}`, {
    address,
})
    .write();
export const getEthersSigners = async () => await Promise.all(await DRE.ethers.getSigners());
export const getEthersSignersAddresses = async () => await Promise.all((await DRE.ethers.getSigners()).map((signer) => signer.getAddress()));
export const getCurrentBlock = async () => {
    return DRE.ethers.provider.getBlockNumber();
};
export const decodeAbiNumber = (data) => parseInt(utils.defaultAbiCoder.decode(['uint256'], data).toString());
export const deployContract = async (contractName, args) => {
    const contract = (await (await DRE.ethers.getContractFactory(contractName)).deploy(...args));
    await waitForTx(contract.deployTransaction);
    await registerContractInJsonDb(React.createElement("eContractid", null,
        "contractName, contract); return contract; }; export const withSaveAndVerify = async ",
        React.createElement(ContractType, { extends: true, Contract: true },
            "( instance: ContractType, id: string, args: (string | string[])[], verify?: boolean, customId?: string ): Promise",
            React.createElement(ContractType, null,
                " => ",
                await waitForTx(instance.deployTransaction),
                "; await registerContractInJsonDb(customId || id, instance); if (verify) ",
                await verifyContract(id, instance.address, args),
                "; } return instance; }; export const getContract = async ",
                React.createElement(ContractType, { extends: true, Contract: true },
                    "( contractName: string, address: string ): Promise",
                    React.createElement(ContractType, null,
                        " => (await DRE.ethers.getContractAt(contractName, address)) as ContractType; export const linkBytecode = (artifact: Artifact, libraries: any) => ",
                        let,
                        " bytecode = artifact.bytecode; for (const [fileName, fileReferences] of Object.entries(artifact.linkReferences)) ",
                    ,
                        "for (const [libName, fixups] of Object.entries(fileReferences)) ",
                    ,
                        "const addr = libraries[libName]; if (addr === undefined) ",
                    ,
                        "continue; } for (const fixup of fixups) ",
                        bytecode =
                            bytecode.substr(0, 2 + fixup.start * 2) +
                                addr.substr(2) +
                                bytecode.substr(2 + (fixup.start + fixup.length) * 2),
                        "; } } } return bytecode; };"))))));
};