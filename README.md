Capx DAO 
====================================

The project provides decentralized Governance system where one can make the proposals and vote on the current proposals.
Voting Power and Propositional Power is calculated on based on staked erc20 capx tokens. For more details see Voting Escrow readme file.


Deploying the Smart Contracts
================================

The deployment script is written in the migrations folder. 
This project has total of 5 contracts which have to be deployed in the following order. 

    2_deploy_ERC20CRV.js
    3_deploy_VotingEscrow.js
    4_deploy_GovernanceStrategy.js
    5_deploy_AaveGovernanceV2.js
    6_deploy_Executor.js

To deploy the contracts in the Rinkeby network, enter the following commands into the terminal window: 

    truffle migrate network --rinkeby

Once the truffle console opens, enter the following command to deploy all the contracts. 

    migrate -f 2 --to 6

This will deploy all the contracts to the rinkeby network and now you can interact with the smart contracts.

Implementation Details 
======================

### ERC20CRV Contract

The ERC20CRV contract is the general erc20 token contract for capx token. It provides all erc20 token functionalities like mining, transferring, checking balance etc.


### VotingEscrow Contract

The Voting Escrow contract is the contract by which user can stake his/her erc20 Capx tokens and get voting and Propositional power. User stake the erc20 by locking there erc20 tokens for some period of time.
User can increase the amount or increase the unlock time after creating the lock. Voting power decreases as the  remaining lock duration decreases.

### AaveGovernanceV2 Contract

This contract is used for creating proposals, Submit vote , cancel proposals, queue proposals and execute proposals.
For more information  see AaveGovernanceV2 readme.

