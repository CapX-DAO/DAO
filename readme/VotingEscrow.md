
# Voting Escrow 

Votes have a weight depending on time, so that the users are committed to whatever they are voting for.
Vote weight linearly decays over time. 

## Methods in VotingEscrow

### 1. commitTransferOwnership
*function commitTransferOwnership(address addr)*
- Parameters:
   - addr-  address of the future admin

- Emits:
  - CommitOwnership(addr)
 
- Method transfers ownership to future owner
- Can be called by admin only


### 2. applyTransferOwnership
*function applyTransferOwnership()*
- Method makes the future admin the current admin
- Callable by the current admin. 
- Method can be called only before the execution state of the proposal.
- Emits: 
    - ApplyOwnership(admin)

### 3. commitSmartWalletChecker
*function applySmartWalletChecker(address addr)*
- Parameters:
    - addr- Address of the future smart wallet checker
- Method sets the future smart wallet checker address
 
### 4. applySmartWalletChecker
*function applySmartWalletChecker()*
- Method makes the future smart wallet checker the current smart wallet checker
 
### 5. assertNotContract
*function assertNotContract(address addr)*
- Parameters:
    - addr-  address of the contract  
- Method asserts the contract isn’t a smart contract depositor
 
### 6. unintToInt
*function uintToInt(uint num)*
- Parameters:
    - num- unsigned int to be converted to int
- Method to convert unsigned int to int

 
 
### 7. intToUint
*function intToUint(int num)*
- Parameters:
    - num- int to be converted to unsigned int
- Method converts int to unsigned int

### 8. getLastUserSlope()
*function getLastUserSlope(address addr)*
- Parameters: 
    - addr- address of the user
- Method gets last slope of the user
 
### 9. lockedEnd()
*function lockedEnd(address addr)*
- Parameters:
    - addr- address of the user
- Method returns when the lock for given user ends
 
### 10. _checkpoint()
*function _checkpoint(address addr, LockedBalance memory oldLocked, LockedBalance memory newLocked)*
- Parameters:
    - addr: User’s wallet address
    - oldLocked: (Previous locked amount)/(end lock time for the user)
    - NewLocked: (New locked amount)/(end lock time for the user)
- Method records global and per-user data to checkpoint

### 11. _depositFor
*function _depositFor(address addr, uint256 _value, uint256 unlockTime, LockedBalance memory LockedBalance, int128 _type)*
- Parameters: 
    - addr: User’s wallet address
    - _value: Amount to deposit
    - unlockTime: New time when to unlock the tokens, or 0 if unchanged
    - LockedBalance: (Previous locked amount)/Timestamp
- Method deposits and locks tokens for a user
- Emits:
    - Deposit(_addr, _value, _locked.end, _type, block.timestamp)
    - Supply(supplyBefore, supplyBefore + _value)
 
### 12. checkpoint()
*function checkpoint()*
- Method records global data to record

 
### 13. depositFor()
*function depositFor(address _addr,, uint256 _val)*
- Parameters: 
    - addr- User’s wallet address
    - _value: Amount to add to the user’s lock
- Method deposits ‘_value’ tokens for ‘_addr’ and adds to the lock

 
### 14. createLock()
*function createLock(uint256 _value, uint256 _unlockTime)*
- Parameter: 
    - _value: Amount to deposit
    - _unlockTime: Epoch time when tokens unlock, rounded down to two whole weeks
- Method deposits ‘_value’ tokens for ‘msg.sender’ and lock until ‘_unlockTime’

 
### 15. increaseAmount()
*function increaseAmount(uint256 _value)*
- Parameters: 
    - _value: Amount of tokens to deposit and add to the lock
- Method deposits ‘_value’ additional tokens for ‘msg.sender’ without modifying the unlock time

 
### 16. increaseUnlockTime()
*function increaseUnlockTime(uint256 _unlockTime)*
- Parameters: 
    - _unlockTime: New epoch time for unlocking 
- Method extends the unlock time for ‘msg.sender’ to ‘_unlockTime’


 
### 17. withdraw()
*function withdraw()*
- Method withdraws all tokens for ‘msg.sender’, allowed only if the lock has expired
- Emits:
    - Withdraw(msg.sender, oldLocked, _locked)
    - Supply(supplyBefore, supplyBefore-value)
 
### 18. findBlockEpoch()
*function findBlockEpoch(uint256 _block, uint256 maxEpoch)*
- Parameters:
    - _block- Block to find
    - maxEpoch- Shouldn’t exceed this epoch while searching

- Returns: Approximate timestamp for the given block

- Method uses binary search to estimate timestamp for block number

### 19. getVotingPowerAt()
*function getVotingPowerAt(address addr, uint256 _t)*
- Parameters: 
    - addr- address of the user whose balance needs to be fetched
    - _t: Epoch time to return voting power at
- Returns: User voting power
- Method returns the voting power of user
 
### 20. balanceOf()
*function balanceOf(address addr,uint256 _t)* 
- Parameters: 
    - addr- address of the user whose balance needs to be fetched
    - _t- Epoch time to return voting power at
- Returns: User voting power
- Method returns the voting power of given user

### 21. balanceOf()
*function balanceOf(address addr )*
- Parameters:
    - addr- User wallet address
- Returns: User voting power 
- Method returns the voting power of given user
 
### 22. _balanceOfAt()
 *function _balanceOfAt(address addr,uint256 _block)*
- Parameters:
    - addr- User’s wallet address
    - _block: Block to calculate the voting power at
- Returns: Voting power of ‘addr’ at height ‘_block’
- Method used to measure voting power of ‘addr’ at height ‘_block’
 
### 23. supplyAt()
*function supplyAt(Point memory point, uint256 t)*
- Parameters:
    - point: the point to start search from
    - t: Time to calculate the total voting power at
- Returns total voting power at time T
- Method is used to calculate total voting power at some point in the past
 

### 24. totalSUpplyAtEpoch()
*function totalSupplyatEpoch(uint256 t)*
- Parameters: 
    - t: time at which voting power needs to be found
- Returns: Voting power
- Method calculates total voting power at time t
 
### 25. totalSupplyAt()
*function totalSupplyAt(uint256 _block)*
- Parameters: 
    - _block: block to calculate the total voting power at
- Returns: Total Voting power at some point in the past
- Method calculates total voting power at some point in the past

### 26. changeController()
*function changeController(controller newController)*
- Dummy method required for Aragon compatibility
