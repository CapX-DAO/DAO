# AaveGovernanceV2 #

- Contract performs various operations on proposal such as create proposal, cancel proposal, queue proposal, execute proposal and submit proposal.

- Proposal passes through Pending => Active => Succeeded(/Failed) => Queued => Executed(/Expired) states.

- The transition to "Cancelled" can be performed from multiple states.


##  Modifiers in contract: ## 

onlyGuardian()


- Verifies whether msg.sender is guardian 

- If msg.sender is guardian then the next code flow of function where the modifier is called will be executed else returns message ONLY\_BY\_GUARDIAN.



##  Methods in AaveGovernanceV2 ##



### .create() ###

function create(IExecutorWithTimelock executor,address[] memory targets,uint256[] memory values,string[] memory signatures,bytes[] memory calldatas, bool[] memory withDelegatecalls, bytes32 ipfsHash  )

Parameters : 

- Executor -  address of the Executor contract that will execute the proposal

- targets - list of contracts called by proposal's associated transactions

  (we’re currently using the address of the dummy contract for the target)

- values - list of value in wei for each propoposal's associated transaction

- signatures - list of function signatures (can be empty) to be used when created the callData

  (for testing, this will be the setVal function in string, This can be found in the Dummy1 contract)

- calldatas- list of calldatas: if associated signature empty, calldata ready, else calldata is arguments

- withDelegatecalls -boolean, true = transaction delegatecalls the target, else calls the target

- ipfsHash- IPFS hash of the proposal

  (we’re using 0x7465737400000000000000000000000000000000000000000000000000000000)

Returns:  proposition id of the created proposal



Method creates proposal for specific executor.

Proposition power of the creator must be greater than equal to proposition\_threshold to create a proposal.

### cancel( ) ###

function cancel(uint256 proposalId)

Parameters :

-  proposalId- id of the proposal

Method cancels proposal

Callable by the \_guardian with relaxed conditions, or by anybody if the conditions of cancellation on the executor are fulfilled.

Method can be called only before the execution state of the proposal.

### queue() ###

function queue(uint256 proposalId)

Parameters: 
- proposalId- id of the proposal

Method queues proposal only if the proposal succeeded.


### execute() ###

function execute(uint256 proposalId)

Parameters: 
- proposalId- id of the proposal

Method executes a proposal only if the proposal is in a queued state.

Method is defined with payable access modifier as some amount of ethers need to be sent while calling execute method.



### submitVote ###

submitVote(uint256 proposalId, bool support)

Parameters:

- proposalId- id of the proposal

- support -boolean, true = vote for, false = vote against

Method returns call to \_ submitVote(msg.sender, proposalId, support) method.



### submitVoteBySignature ###

function submitVoteBySignature(uint256 proposalId,bool support,uint8 v,bytes32 r,bytes32 s

Parameters:

- proposalId- id of the proposal

- support -boolean, true = vote for, false = vote against

- v -v part of the voter signature

- r- r part of the voter signature

- s- s part of the voter signature

Method to register the vote of user that has voted offchain via signature.



### setGovernanceStrategy() ###

function setGovernanceStrategy(address governanceStrategy)

Parameters :
- governanceStrategy- new Address of the GovernanceStrategy contract

Method Sets new GovernanceStrategy

Method is defined with OnlyOwner modifier. Hence,method should be executed by timelocked executor only.

Method returns call to   \_setGovernanceStrategy(governanceStrategy) method .



### setVotingDelay() ###

function setVotingDelay(uint256 votingDelay)

Parameters : 

- votingDelay- new voting delay in terms of blocks

Method sets new Voting Delay i.e delay before a newly created proposal can be voted on

Method is defined with OnlyOwner modifier. Hence,method should be executed by timelocked executor only.



### authorizeExecutors() ###

function authorizeExecutors(address[] memory executors)

Parameters: 
- executors list of new addresses to be authorized executors

Method adds new addresses to the list of authorized executors.

Method is defined with OnlyOwner modifier. Hence,method should be executed by timelocked executor only.

Method returns a call to  \_authorizeExecutor(executors[]) method.



### unauthorizeExecutors() ###

function unauthorizeExecutors(address[] memory executors)

Parameters :
- executors list of addresses to be removed as authorized executors

Method Remove addresses to the list of authorized executors.

Method is defined with OnlyOwner modifier. Hence,method should be executed by timelocked executor only.

Method returns call to  \_unauthorizeExecutor(executors[]) method.



### \_\_abdicate() ###

function \_\_abdicate()

Method allows guardian to abdicate from its privileged rights.

Method is defined with onlyGuardian modifier. Hence,the method should be executed by guardian only.

Method sets a new guardian address to the first address from the list of addresses(address[0]).



### \_setGovernanceStrategy ###

function \_setGovernanceStrategy(address governanceStrategy)

Parameters : 

- governanaceStrategy-  new Address of the GovernanceStrategy contract

Method is used to set governanceStrategy.



### \_setVotingDelay() ###

function \_setVotingDelay(uint256 votingDelay)

Parameters :

- votingDelay – new voting delay in terms of blocks.

- Method is used to set the value of voting delay.



### \_authorizeExecutor() ###

function \_authorizeExecutor(address executor)

Parameters : 

- executor-address of executor

Method authorizes executor

Method sets the given address to true in the list of authorized executors list .



### \_unauthorizeExecutor() ###

function \_unauthorizeExecutor(address executor)

Parameters : 

- executor- address of the executor

Method unauthorizes executor

Method sets the given address to false in the list of authorized executors.

