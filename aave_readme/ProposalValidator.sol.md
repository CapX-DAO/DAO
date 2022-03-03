## ProposalValidator.sol

- Contract inherited by  Aave Governance Executors
- Validates/Invalidations propositions state modifications.
 * Proposition Power functions: Validates proposition creations/ cancellation
 * Voting Power functions: Validates success of propositions.

### Constants

 - `uint256 public constant override ONE_HUNDRED_WITH_PRECISION = 10000:`     
    		Equivalent to 100%, but scaled for precision.
### Variables
- `uint256 public immutable override PROPOSITION_THRESHOLD`:     
   Minimum percentage of supply needed to submit a proposal.
- `uint256 public immutable override VOTING_DURATION`:      
   Duration in blocks of the voting period.

- `uint256 public immutable override VOTE_DIFFERENTIAL`:   
   Percentage of supply that `for` votes need to be over `against` in order for the proposal to pass.In ONE_HUNDRED_WITH_PRECISION units.

- `uint256 public immutable override MINIMUM_QUORUM`:  
   Minimum percentage of the supply in FOR-voting-power need for a proposal to pass .In ONE_HUNDRED_WITH_PRECISION units.




### Functions

**validateCreatorOfProposal**

```solidity 
function validateCreatorOfProposal(IAaveGovernanceV2 governance,address user,uint256 blockNumber) external view override returns (bool)
```

Inputs required

- `Governance`- Governance Contract
- `user`- Address of the proposal creator
- `blockNumber`- Block Number against which to make the test (e.g proposal creation block -1)

Returns

- boolean, true if proposal can be created

Functionality:

- Method called to validate a proposal, when creating a new proposal in Governance.

- Method returns a call to isPropositionPowerEnough(governance, user, blockNumber) method.

**validateProposalCancellation**

```solidity 
function validateProposalCancellation(IAaveGovernanceV2 governance,address user,uint256 blockNumber) external view override returns (bool)
```

Inputs required

- `governance` -Governance Contract

- `user`- Address of the proposal creator

- `blockNumber`- Block Number against which to make the test (e.g proposal creation block -1)

Returns

- boolean, true if proposal can be cancelled

Functionality:

-Method is called to validate the cancellation of a proposal.
-Needs to the creator to have lost proposition power threshold.

**isPropositionPowerEnough**

```solidity 
function isPropositionPowerEnough(IAaveGovernanceV2 governance,address user,uint256 blockNumber) public view override returns (bool)
```

Inputs required

- `Governance`- Governance Contract

- `user` -Address of the user to be challenged.

- `blockNumber`- Block Number against which to make the challenge.

Returns

- true, if user has enough power

 Functionality:

- Method checks whether a user has enough proposition power to make a proposal by comparing current proposition power with minimum proposition power needed.

- Method fetches proposition power by calling getPropositionPowerAt(user, blockNumber) method of GovernanaceStrategy contract.

- Method fetches minimum power needed by making a call to getMinimumPropositionPowerNeeded(governance, blockNumber) method.

**getMinimumPropositionPowerNeeded**

```solidity 
function getMinimumPropositionPowerNeeded(IAaveGovernanceV2 governance, uint256 blockNumber) public view override returns (uint256)
```

Inputs required

- `governance`- Governance Contract

- `blockNumber`- Blocknumber at which to evaluate

Returns

- minimum Proposition Power needed to create a proposition

Functionality:

- Method makes a call to getTotalPropositionSupplyAt(blockNumber) of GovernanceStrategy method to get total proposition supply at specified block number.

- Minimum proposition power calculated by
 (PROPOSITION_THRESHOLD*total proposition supply)/ONE_HUNDRED_WITH_PRECISION

**isProposalPassed**

```solidity 
function isProposalPassed(IAaveGovernanceV2 governance, uint256 proposalId) public view override returns (bool)
```

Inputs required

- `Governance`- Governance Contract

- `proposalId`- Id of the proposal to set

Returns

- true, if proposal passed

Functionality:

- Method checks whether a proposal passed or not.

- Method returns true if call to isQuorumValid(governance, proposalId) and isVoteDifferentialValid(governance, proposalId) both these methods returns true.

**getMinimumVotingPowerNeeded**

```solidity 
function getMinimumVotingPowerNeeded(uint256 votingSupply) public view override returns (uint256)
```

Inputs required

- `votingSupply`- Total number of outstanding voting tokens

Returns

 - voting power needed for a proposal to pass

Functionality:

- Method calculates minimum amount of Voting Power needed for a proposal to pass

- Minimum voting power calculated by (votingSupply*MINIMUM_QUORUM)/ ONE_HUNDRED_WITH_PRECISION

**isQuorumValid**

```solidity 
function isQuorumValid(IAaveGovernanceV2 governance, uint256 proposalId) public view override returns (bool)
```

Inputs required

- `governance`- Governance Contract

- `proposalId`- Id of the proposal to verify

Returns

- true ,if proposal has enough FOR-voting-power

Functionality:

- Method checks whether a proposal has reached quorum, i.e proposal has enough FOR-voting-power

- Method compares proposal for votes with minimum voting power needed(fetched by calling getMinimumVotingPowerNeeded(votingSupply))

**isVoteDifferentialValid**

```solidity 
function isVoteDifferentialValid(IAaveGovernanceV2 governance, uint256 proposalId) public view override returns (bool)
```

Inputs required

- `governance` -Governance Contract

- `proposalId` -Id of the proposal to verify

Returns

- true, if enough For-Votes

Functionality:

- Method checks whether a proposal has enough extra FOR-votes than AGAINST-votes
 ( FOR VOTES - AGAINST VOTES )> VOTE_DIFFERENTIAL * voting supply
