## GovernanceStrategy.sol

- Smart contract containing logic to measure users' relative power to propose and vote.
- User Power = User Power from Aave Token + User Power from stkAave Token.
- User Power from Token = Token Power + Token Power as Delegatee [- Token Power if user has delegated]
- Two wrapper functions linked to Aave Tokens's GovernancePowerDelegationERC20.sol implementation
- getPropositionPowerAt: fetching a user Proposition Power at a specified block
- getVotingPowerAt: fetching a user Voting Power at a specified block

### Variables
- `address public immutable VECRV`:

   Address of the AAVE/ stkAave Token contract.



### Functions

**get_block_number**

```solidity 
function get_block_number public view returns (uint256)
```

Returns
- current block number

**getTotalPropositionSupplyAt**

```solidity
function getTotalPropositionSupplyAt(uint256 blockNumber) public view override returns (uint256)
```

Inputs required

`blockNumber` -Blocknumber at which to evaluate

Returns

- total  proposition supply at blockNumber

Functionality:

- Total supply of Proposition Tokens Available for Governance
   AAVE Available for governance + stkAAVE available

- The supply of AAVE staked in stkAAVE are not taken into account so:
(Supply of AAVE - AAVE in stkAAVE) + (Supply of stkAAVE) = Supply of AAVE, Since the supply of  stkAAVE is equal to the number of AAVE staked.

**getTotalVotingSupplyAt**

```solidity 
function getTotalVotingSupplyAt(uint256 blockNumber) public view override returns (uint256)
```

Inputs required

- `blockNumber`- Blocknumber at which to evaluate

Returns

- total voting  supply at blockNumber

Functionality:

- Total supply of Outstanding Voting Tokens fetched  by calling totalSupplyAt(blockNumber) method of VotingEscrow contract..

**getPropositionPowerAt**

```solidity 
function getPropositionPowerAt(address user, uint256 blockNumber) public view override returns (uint256)
```

Inputs required

- `User`- Address of the user.
- `blockNumber`- Blocknumber at which to fetch Proposition Power

Returns

- power number

Functionality:

- Method returns the proposition Power of a user at a specific block number.
- Proposition power fetched by calling balanceOfAt(user, blockNumber) method of VotingEscrow contract.

**getVotingPowerAt**

```solidity 
function getVotingPowerAt(address user, uint256 blockNumber) public view override returns (uint256)
```

Inputs required

- `User`- Address of the user.
- `blockNumber`- Blocknumber at which to fetch Vote Power

Returns

- voting number

Functionality:

- Method finds the vote Power of a user at a specific block number.
- Voting power fetched by calling balanceOfAt(user, blockNumber) method of VotingEscrow contract.

