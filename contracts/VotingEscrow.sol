// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../dependencies/open-zeppelin/ERC20.sol";
import "../dependencies/open-zeppelin/ReentrancyGuard.sol";
import {SafeCast} from "../dependencies/open-zeppelin/SafeCast.sol";
import {SignedSafeMath} from "../dependencies/open-zeppelin/SignedSafeMath.sol";


//  @title Voting Escrow
//  @author Curve Finance
//  @license MIT
//  @notice Votes have a weight depending on time, so that users are
        //  committed to the future of (whatever they are voting for)
//  @dev Vote weight decays linearly over time. Lock time cannot be
      // more than `MAXTIME` (4 years).
// Voting escrow to have time-weighted votes
// Votes have a weight depending on time, so that users are committed
// to the future of (whatever they are voting for).
// The weight in this implementation is linear, and lock cannot be more than maxtime:
// w ^
// 1 +        /
//   |      /
//   |    /
//   |  /
//   |/
// 0 +--------+------> time
//       maxtime (4 years?)


interface SmartWalletChecker {
  function check(address _wallet) external returns (bool);
}
contract VotingEscrow is ReentrancyGuard{
  
   
// We cannot really do block numbers per se b/c slope is per time, not per block
// and per block could be fairly bad b/c Ethereum changes blocktimes.
// What we can do is to extrapolate ***At functions



struct LockedBalance{
    int128 amount; 
    uint256 end;
}

struct Point{
    int128 bias;
    int128 slope;
    uint256 ts;
    uint256 blk;
}   

    


// Interface for checking whether address belongs to a whitelisted
// type of a smart wallet.
// When new types are added - the whole contract is changed
// The check() method is modifying to be able to use caching
// for individual wallet addresses


    

uint128 constant DEPOSIT_FOR_TYPE = 0;
//DEPOSIT_FOR_TYPE: constant(int128) = 0
int128 constant CREATE_LOCK_TYPE = 1;
int128 constant INCREASE_LOCK_AMOUNT = 2;
int128 constant INCREASE_UNLOCK_TIME = 3;

event CommitOwnership(address admin);

event ApplyOwnership(address admin);

event Deposit(address indexed provider, uint256 value, uint256 indexed lockTime, int128 _type , uint256 ts);

event Withdraw(address indexed provider, uint256 value, uint256 ts);

event Supply(uint256 prevSupply, uint256 supply);

uint256 constant WEEK = 7 * 86400;  
uint256 constant MAXTIME= 4 * 365 * 86400;
uint256 constant MULTIPLIER = 10 ** 18;
address token;
uint256 supply;
mapping(address => LockedBalance) locked;
uint256 epoch;
mapping(uint256 => Point) pointHistory;
mapping(address => mapping(uint256 => Point)) userPointHistory;
mapping(address => uint256) userPointEpoch;
mapping(uint256 => int128) slopeChanges;

address public controller;
bool transfersEnabled;

string name;
string symbol;
string version;
uint8 decimals;

// Checker for whitelisted (smart contract) wallets which are allowed to deposit
// The goal is to prevent tokenizing the escrow

address public futureSmartWalletChecker;
address public smartWalletChecker;

address public admin;  
address public futureAdmin;


  constructor(address tokenAddr,string memory _name,string memory _symbol,string memory _version){
    ///
    /// @notice Contract constructor
    /// @param tokenAddr `ERC20CRV` token address
    /// @param _name Token name
    /// @param _symbol Token symbol
    /// @param _version Contract version - required for Aragon compatibility
    ///
    admin = msg.sender;
    token = tokenAddr;
    
    pointHistory[0] = (Point(
      {
        bias:0,
        slope: 0,
        blk : block.number,
        ts: block.timestamp
      }
    ));
    controller = msg.sender;
    transfersEnabled = true;

    uint8 _decimals = ERC20(tokenAddr).decimals();
    decimals = _decimals;

    name = _name;
    symbol = _symbol;
    version = _version;
  }


  function commitTransferOwnership(address addr) public {
    require(msg.sender == admin, "Only admin can commit transfer ownership");
    futureAdmin = addr;
    emit CommitOwnership(addr);
  }

  function applyTransferOwnership() public {
    
    require(msg.sender == admin, "Only admin can apply transfer ownership");
    address _admin = futureAdmin;
    require(_admin != address(0), "No new admin");
    admin = _admin;
    emit ApplyOwnership(_admin);
  }

  function commitSmartWalletChecker(address addr) public {
    require(msg.sender == admin, "Only admin can commit smart wallet checker");
    futureSmartWalletChecker = addr;
  }

  function applySmartWalletChecker() public {
    require(msg.sender == admin, "Only admin can apply smart wallet checker");
    smartWalletChecker = futureSmartWalletChecker;
  }

  function assertNotContract(address addr) private {
    if (addr != tx.origin){
      address checker = smartWalletChecker;
      if (checker != address(0)){
        require(SmartWalletChecker(checker).check(addr) , "Smart contract depositors not allowed");
      }
    }
  }

  
  

  function uintToInt(uint num) private pure returns (int) {
    return int(num);
  }

  function intToUint(int num) private pure returns (uint) {
    return uint(num);
  }

  function getLastUserSlope(address addr) public view returns (int128) {
    uint256 uEpoch = userPointEpoch[addr];
    return userPointHistory[addr][uEpoch].slope;
  }

  function userPointHistoryTs(address _addr, uint256 _idx) public view returns (uint256) {
    return userPointHistory[_addr][_idx].ts;
  }

  function lockedEnd(address _addr) public view returns (uint256) {
    return locked[_addr].end;
  }

  function _checkpoint(address addr,LockedBalance memory oldLocked , LockedBalance memory newLocked) private {
    ///
    /// @notice Record global and per-user data to checkpoint
    /// @param addr User's wallet address. No user checkpoint if 0x0
    /// @param oldLocked Previous locked amount / end lock time for the user
    /// @param newLocked New locked amount / end lock time for the user
    ///
    Point memory uOld = Point(0,0,0,0);
    Point memory uNew = Point(0,0,0,0);
    int128 oldDSlope = 0;
    int128 newDSlope = 0;
    uint256 _epoch = epoch;

    if (addr != address(0)) {
        // Calculate slopes and biases
        // Kept at zero when they have to
        if (oldLocked.end > block.timestamp && oldLocked.amount > 0){
            uOld.slope = oldLocked.amount / SafeCast.toInt128(uintToInt(MAXTIME));
            uOld.bias = uOld.slope * SafeCast.toInt128(uintToInt(oldLocked.end - block.timestamp));
        }
        if (newLocked.end > block.timestamp && newLocked.amount > 0){
            uNew.slope = newLocked.amount / SafeCast.toInt128(uintToInt(MAXTIME));
            uNew.bias = uNew.slope * SafeCast.toInt128(uintToInt(newLocked.end - block.timestamp));
        }

        // Read values of scheduled changes in the slope
        // oldLocked.end can be in the past and in the future
        // newLocked.end can ONLY by in the FUTURE unless everything expired: than zeros
        oldDSlope = slopeChanges[oldLocked.end];
        if (newLocked.end != 0) {
            if (newLocked.end == oldLocked.end) {
                newDSlope = oldDSlope;
            } else {
                newDSlope = slopeChanges[newLocked.end];
            }
        }
    }
    Point memory lastPoint = Point({bias: 0, slope: 0, ts: block.timestamp, blk: block.number});
    if (_epoch > 0) {
        lastPoint = pointHistory[_epoch];
    }
    uint256 lastCheckpoint = lastPoint.ts;
    // initialLastPoint is used for extrapolation to calculate block number
    // (approximately, for *At methods) and save them
    // as we cannot figure that out exactly from inside the contract
    Point memory initialLastPoint = lastPoint;
    uint256 blockSlope = 0 ;  // dblock/dt
    if (block.timestamp > lastPoint.ts) {
        blockSlope = MULTIPLIER * (block.number - lastPoint.blk) / (block.timestamp - lastPoint.ts);
    }
    // If last point is already recorded in this block, slope=0
    // But that's ok b/c we know the block in such case

    // Go over weeks to fill history and calculate what the current point is
    uint256 tI  = (lastCheckpoint / WEEK) * WEEK;
    for (uint16 i = 0; i < 255; i++) {
      // Hopefully it won't happen that this won't get used in 5 years!
      // If it does, users will be able to withdraw but vote weight will be broken
      tI += WEEK;
      int128 dSlope = 0;
      if (tI > block.timestamp) {
          tI = block.timestamp;
      } else {
          dSlope = slopeChanges[tI];
      }
      lastPoint.bias -= lastPoint.slope * SafeCast.toInt128(uintToInt(tI - lastCheckpoint));
      lastPoint.slope += dSlope;
      if (lastPoint.bias < 0){  // This can happen
          lastPoint.bias = 0;
      }
      if (lastPoint.slope < 0) {  // This cannot happen - just in case
          lastPoint.slope = 0;
      }
      lastCheckpoint = tI;
      lastPoint.ts = tI;
      lastPoint.blk = initialLastPoint.blk + blockSlope * (tI - initialLastPoint.ts) / MULTIPLIER;
      _epoch += 1;
      if (tI == block.timestamp) {
          lastPoint.blk = block.number;
          break;
      } else {
          pointHistory[_epoch] = lastPoint;
      }
      
    }
    epoch = _epoch;
    // Now pointHistory is filled until t=now

    if (addr != address(0)) {
        // If last point was in this block, the slope change has been applied already
        // But in such case we have 0 slope(s)
        lastPoint.slope += (uNew.slope - uOld.slope);
        lastPoint.bias += (uNew.bias - uOld.bias);
        if (lastPoint.slope < 0) {
            lastPoint.slope = 0;
        }
        if (lastPoint.bias < 0) {
            lastPoint.bias = 0;
        }
    }
    // Record the changed point into history
    pointHistory[_epoch] = lastPoint;

    if (addr != address(0)) {
        // Schedule the slope changes (slope is going down)
        // We subtract new_user_slope from [newLocked.end]
        // and add old_user_slope to [oldLocked.end]
        if (oldLocked.end > block.timestamp) {
            // oldDSlope was <something> - uOld.slope, so we cancel that
            oldDSlope += uOld.slope;
            if (newLocked.end == oldLocked.end) {
                oldDSlope -= uNew.slope;  // It was a new deposit, not extension
            }
            slopeChanges[oldLocked.end] = oldDSlope;
        }

        if (newLocked.end > block.timestamp){
            if (newLocked.end > oldLocked.end) {
                newDSlope -= uNew.slope;  // old slope disappeared at this point
                slopeChanges[newLocked.end] = newDSlope;
            }
            // else: we recorded it already in oldDSlope
        }
        // Now handle user history
        _epoch = userPointEpoch[addr] + 1;

        userPointEpoch[addr] = _epoch;
        uNew.ts = block.timestamp;
        uNew.blk = block.number;
        userPointHistory[addr][_epoch] = uNew;
    }
  }

  function _depositFor(address _addr ,uint256 _value, uint256 unlockTime, LockedBalance memory lockedBalance,int128 _type) private {
    ///
    /// @notice Deposit and lock tokens for a user
    /// @param _addr User's wallet address
    /// @param _value Amount to deposit
    /// @param unlockTime New time when to unlock the tokens, or 0 if unchanged
    /// @param lockedBalance Previous locked amount / timestamp
    ///
    LockedBalance memory _locked  = lockedBalance;
    uint256 supplyBefore = supply;

    supply = supplyBefore + _value;
    LockedBalance memory oldLocked = locked[_addr];
    // Adding to existing lock, or if a lock is expired - creating a new one
    _locked.amount += SafeCast.toInt128(uintToInt(_value));
    if (unlockTime != 0) {
        _locked.end = unlockTime;
    }
    locked[_addr] = _locked;
    
    // Possibilities:
    // Both oldLocked.end could be current or expired (>/< block.timestamp)
    // value == 0 (extend lock) or value > 0 (add to lock or extend lock)
    // _locked.end > block.timestamp (always)
    _checkpoint(_addr, oldLocked, _locked);

    if (_value != 0) {
        require(ERC20(token).transferFrom(_addr, address(this), _value));
    }

    emit Deposit(_addr, _value, _locked.end, _type, block.timestamp);
    emit Supply(supplyBefore, supplyBefore + _value);
  }

  function checkpoint() public {
    ///
    /// @notice Record global data to checkpoint
    ///
    _checkpoint(address(0), LockedBalance(0,0), LockedBalance(0,0));
  }

  function depositFor(address _addr,uint256 _value) public nonReentrant {

    ///
    /// @notice Deposit `_value` tokens for `_addr` and add to the lock
    /// @dev Anyone (even a smart contract) can deposit for someone else, but
    //      cannot extend their lockTime and deposit for a brand new user
    /// @param _addr User's wallet address
    /// @param _value Amount to add to user's lock
    ///

    LockedBalance memory _locked = locked[_addr];

    require(_value>0,"need non-zero value"); 
    require(_locked.amount > 0, "No existing lock found");
    require(_locked.end > block.timestamp, "Cannot add to expired lock. Withdraw");

    _depositFor(_addr, _value, 0, locked[_addr], SafeCast.toInt128(uintToInt(DEPOSIT_FOR_TYPE)));
  }

  function createLock(uint256 _value, uint256 _unlockTime) public nonReentrant {
    ///
    /// @notice Deposit `_value` tokens for `msg.sender` and lock until `_unlockTime`
    /// @param _value Amount to deposit
    /// @param _unlockTime Epoch time when tokens unlock, rounded down to whole weeks
    ///
    assertNotContract(msg.sender);
    
    uint256 unlockTime = (_unlockTime / WEEK) * WEEK; // Locktime is rounded down to weeks
    LockedBalance memory _locked = locked[msg.sender];

    require(_value > 0,"need non-zero value");
    require(_locked.amount == 0, "Withdraw old tokens first");
    require(unlockTime > block.timestamp, "Can only lock until time in the future");
    require(unlockTime <= block.timestamp + MAXTIME, "Voting lock can be 4 years max");

    _depositFor(msg.sender, _value, unlockTime, _locked, CREATE_LOCK_TYPE);
  }

  function increaseAmount(uint256 _value) public nonReentrant {
    ///
    /// @notice Deposit `_value` additional tokens for `msg.sender`
    //         without modifying the unlock time
    /// @param _value Amount of tokens to deposit and add to the lock
    ///
    assertNotContract(msg.sender);
    LockedBalance memory _locked = locked[msg.sender];

    require(_value > 0,"need non-zero value");
    require(_locked.amount > 0, "No existing lock found");
    require(_locked.end > block.timestamp, "Cannot add to expired lock. Withdraw");

    _depositFor(msg.sender, _value, 0, _locked, INCREASE_LOCK_AMOUNT);
  }

  function increaseUnlockTime(uint256 _unlockTime) public nonReentrant {
    ///
    /// @notice Extend the unlock time for `msg.sender` to `_unlockTime`
    /// @param _unlockTime New epoch time for unlocking
    ///
    assertNotContract(msg.sender);
    LockedBalance memory _locked = locked[msg.sender];
    uint256 unlockTime = (_unlockTime / WEEK) * WEEK ; // Locktime is rounded down to weeks

    require(_locked.end > block.timestamp, "Lock expired");
    require(_locked.amount > 0, "Nothing is locked");
    require(unlockTime > _locked.end, "Can only increase lock duration");
    require(unlockTime <= block.timestamp + MAXTIME, "Voting lock can be 4 years max");

    _depositFor(msg.sender, 0, unlockTime, _locked, INCREASE_UNLOCK_TIME);
  }

  function withdraw() public nonReentrant {
    ///
    /// @notice Withdraw all tokens for `msg.sender`
    /// @dev Only possible if the lock has expired
    ///
    LockedBalance memory _locked = locked[msg.sender];
    require(block.timestamp >= _locked.end, "The lock didn't expire");
    uint256 value = intToUint(_locked.amount);

    LockedBalance memory oldLocked = _locked;
    _locked.end = 0;
    _locked.amount = 0;
    locked[msg.sender] = _locked;
    uint256 supplyBefore = supply;
    supply = supplyBefore - value;

    // oldLocked can have either expired <= timestamp or zero end
    // _locked has only 0 end
    // Both can have >= 0 amount
    _checkpoint(msg.sender, oldLocked, _locked);

    require(ERC20(token).transfer(msg.sender, value));

    emit Withdraw(msg.sender, value, block.timestamp);
    emit Supply(supplyBefore, supplyBefore - value);
  }

  function findBlockEpoch( uint256 _block,uint256 maxEpoch) private view returns (uint256) {
    ///
    /// @notice Binary search to estimate timestamp for block number
    /// @param _block Block to find
    /// @param maxEpoch Don't go beyond this epoch
    /// @return Approximate timestamp for block
    ///
    // Binary search
    uint256 _min= 0;
    uint256 _max = maxEpoch;
    for (uint256 i = 0; i < 128; i++) {
      if (_min >= _max) {
            break;
      }
      uint256 _mid = (_min + _max + 1) / 2;
      if (pointHistory[_mid].blk <= _block){
        _min = _mid;
      } else{
        _max = _mid - 1;
      }
    }
    
    return _min;
  }

  function getVotingPowerAt(address addr , uint256 _t) public view returns (uint256) {
    return balanceOf(addr,_t);
  }

  function balanceOf(address addr,uint256 _t ) public view returns(uint256) {
    ///
    /// @notice Get the current voting power for `msg.sender`
    /// @dev Adheres to the ERC20 `balanceOf` interface for Aragon compatibility
    /// @param addr User wallet address
    /// @param _t Epoch time to return voting power at
    /// @return User voting power
    ///
    uint256 _epoch = userPointEpoch[addr];
    if (_epoch == 0) {
        return 0;
    } else {
        Point memory lastPoint = userPointHistory[addr][_epoch];
        lastPoint.bias -= lastPoint.slope * SafeCast.toInt128(SignedSafeMath.sub(uintToInt(_t),uintToInt(lastPoint.ts)));
        if (lastPoint.bias < 0){
            lastPoint.bias = 0;
        }
        return intToUint(lastPoint.bias);
    }
  }

  // Function overloaded due to solidity limitations
  // cannot default parameter values
  function balanceOf(address addr ) public view returns(uint256) {
    ///
    /// @notice Get the current voting power for `msg.sender`
    /// @dev Adheres to the ERC20 `balanceOf` interface for Aragon compatibility
    /// @param addr User wallet address
    /// @param _t Epoch time to return voting power at
    /// @return User voting power
    ///
    uint256 _t = block.timestamp;
    uint256 _epoch = userPointEpoch[addr];
    if (_epoch == 0) {
        return 0;
    } else {
        Point memory lastPoint = userPointHistory[addr][_epoch];
        lastPoint.bias -= lastPoint.slope * SafeCast.toInt128(uintToInt(_t - lastPoint.ts));
        if (lastPoint.bias < 0){
            lastPoint.bias = 0;
        }
        return intToUint(lastPoint.bias);
    }
  }

  function balanceOfAt(address addr,uint256 _block) public view returns(uint256) {
    ///
    /// @notice Measure voting power of `addr` at block height `_block`
    /// @dev Adheres to MiniMe `balanceOfAt` interface: https://github.com/Giveth/minime
    /// @param addr User's wallet address
    /// @param _block Block to calculate the voting power at
    /// @return Voting power
    ///
    // Copying and pasting totalSupply code because Vyper cannot pass by
    // reference yet
    require(_block <= block.number,"Block cannot be in the future");

    // Binary search
    uint256 _min = 0;
    uint256 _max = userPointEpoch[addr];
    for (uint256 i = 0; i < 128; i++) {
      if (_min >= _max) {
            break;
      }
      uint256 _mid = (_min + _max + 1) / 2;
      if (userPointHistory[addr][_mid].blk <= _block){
        _min = _mid;
      } else{
        _max = _mid - 1;
      }      
    }
  
    Point memory upoint = userPointHistory[addr][_min];

    uint256 maxEpoch = epoch;
    uint256 _epoch = findBlockEpoch(_block, maxEpoch);
    Point memory point0 = pointHistory[_epoch];
    uint256 dBlock = 0;
    uint256 dT = 0;
    if (_epoch < maxEpoch) {
        Point memory point1 = pointHistory[_epoch + 1];
        dBlock = point1.blk - point0.blk;
        dT = point1.ts - point0.ts;
    } else {
        dBlock = block.number - point0.blk;
        dT = block.timestamp - point0.ts;
    }
    uint256 blockTime = point0.ts;
    if (dBlock != 0) {
        blockTime += dT * (_block - point0.blk) / dBlock;
    }

    upoint.bias -= upoint.slope * SafeCast.toInt128(uintToInt(blockTime - upoint.ts));
    if (upoint.bias >= 0) {
        return intToUint(upoint.bias);
    } else {
        return 0;
    }
  }

  function supplyAt(Point memory point, uint256 t) public view returns(uint256) {
    ///
    /// @notice Calculate total voting power at some point in the past
    /// @param point The point (bias/slope) to start search from
    /// @param t Time to calculate the total voting power at
    /// @return Total voting power at that time
    ///
    Point memory lastPoint = point;
    uint256 tI = (lastPoint.ts / WEEK) * WEEK;
    for (uint256 i = 0; i < 255; i++) {
      tI += WEEK;
      int128 dSlope = 0;
      if (tI > t) {
          tI = t;
      } else {
          dSlope = slopeChanges[tI];
      }
      lastPoint.bias -= lastPoint.slope * SafeCast.toInt128(uintToInt(tI - lastPoint.ts));
      if (tI == t) {
          break;
      }
      lastPoint.slope += dSlope;
      lastPoint.ts = tI;
      
    }

    if (lastPoint.bias < 0) {
        lastPoint.bias = 0;
    }
    return intToUint(lastPoint.bias);
  }

  function totalSupplyAtEpoch(uint256 t) public view returns(uint256) {
    ///
    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    ///
    uint256 _epoch  = epoch;
    Point memory lastPoint = pointHistory[_epoch];
    return supplyAt(lastPoint, t);
  }

  function totalSupply() public view returns(uint256) {
    ///
    /// @notice Calculate total voting power
    /// @dev Adheres to the ERC20 `totalSupply` interface for Aragon compatibility
    /// @return Total voting power
    ///
    uint256 t = block.timestamp;
    uint256 _epoch  = epoch;
    Point memory lastPoint = pointHistory[_epoch];
    return supplyAt(lastPoint, t);
  }

  function totalSupplyAt(uint256 _block) public view returns(uint256) {
    ///
    /// @notice Calculate total voting power at some point in the past
    /// @param _block Block to calculate the total voting power at
    /// @return Total voting power at `_block`
    ///
    require( _block <= block.number);
    uint256 _epoch = epoch;
    uint256 targetEpoch = findBlockEpoch(_block, _epoch);

    Point memory point = pointHistory[targetEpoch];
    uint256 dt = 0;
    if (targetEpoch < _epoch) {
        Point memory pointNext= pointHistory[targetEpoch + 1];
        if (point.blk != pointNext.blk) {
            dt = (_block - point.blk) * (pointNext.ts - point.ts) / (pointNext.blk - point.blk);
        }
    } else {
        if (point.blk != block.number) {
            dt = (_block - point.blk) * (block.timestamp - point.ts) / (block.number - point.blk);
        }
    }
    // Now dt contains info on how far are we beyond point

    return supplyAt(point, point.ts + dt);
  }

  function changeController(address _newController) public {
    ///
    /// @dev Dummy method required for Aragon compatibility
    ///
    require(msg.sender == controller, "Only controller can change controller"); 
    controller = _newController;
  }

}
