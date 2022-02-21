
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import {VotingEscrowDelegation} from "./VotingEscrowDelegation.sol";
import "../dependencies/open-zeppelin/ERC20.sol";
// import {Utils} from "../dependencies/open-zeppelin/Utils.sol";

interface ERC721Receiver {
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _token_id,
        bytes memory _data
    ) external returns (bytes32);    
}



interface VeDelegation {
    function adjusted_balance_of(address _account) external view returns (uint256);
    function cancel_boost(uint256 _token_id,address _caller) external;
    function update_enumeration_data(address _from,address _to,uint256 _token_id,uint256 balance_of_from,uint256 balance_of_to) external;
    function _burn_boost(uint256 _token_id,address _delegator,address _receiver) external;
    function create_boost(address _delegator,address _receiver,int256 _percentage,uint256 _cancel_time,uint256 _expire_time, uint256 _id) external;
    function extend_boost(uint256 _token_id , int256 _percentage , uint256 _expiry_time ,uint256 _cancel_time,address receiver) external ;
    function _set_delegation_status(address _receiver,address _delegator,bool _status) external;
    function get_boost_token_data(uint256 _token_id) external view returns (uint256);
    function transfer_boost_permission(address _to , address delegator) external view;
    function _transfer_boost(address _from,address _to,int256 _bias,int256 _slope) external;
}

interface Utilsde {
    struct slice {
        uint _len;
        uint _ptr;
    }
    
    function uinttoint(uint num) external pure returns (int) ;
function inttouint(int num) external pure returns (uint) ;
function timechecker(uint256 _expiry_time,uint256 _cancel_time,address delegator,address VOTING_ESCROW) external view returns (uint256) ;
function memcpy(uint dest, uint src, uint len) external pure ;
function toSlice(string memory a) external pure returns (slice memory) ;
function concat(string memory a, string memory b) external pure returns (string memory) ;
function shift(uint256 _x, int256 _n) external pure returns (uint256) ;
function shift(int256 _x, int256 _n) external pure returns (int256) ;
function _uint_to_string(uint256 _x) external pure returns (string memory) ;
function _deconstruct_bias_slope(uint256 _data) external pure returns (VotingEscrowDelegation.Point memory) ;
function _calc_bias_slope(int256 _x,int256 _y,int256 _expire_time) external pure returns (VotingEscrowDelegation.Point memory) ;
function max(uint256 a, uint256 b) external pure returns (uint256) ;
function max(int256 a, int256 b) external pure returns (int256) ;
function abs(int256 a) external pure returns (int256) ;
function get_token_id(address _delegator , uint256 _id) external pure returns (uint256) ;
function is_contract(address _addr) external view returns (bool isContract);
function received_boost(uint256 boost_recieved) external view returns (uint256) ;
function _is_approved_or_owner(address _spender,address owner_of_token_id, address get_approved_token_id , bool isapprovedforall_owner_spender) external pure ;
function adjusted_balance_of(address _account,VotingEscrowDelegation.Boost memory boost_account,address VOTING_ESCROW) external view returns (uint256);
function ycalc(address _delegator,VotingEscrowDelegation.Point memory point, int256 _percentage,address VOTING_ESCROW) external view returns (int256) ;
function delegated_boost(address _account,VotingEscrowDelegation.Boost memory boost_account) external view returns (uint256) ;
function calc_boost_bias_slope(
    address _delegator,
    int256 _percentage,
    int256 _expire_time,
    uint256 _extend_token_id,
    uint256 boost_delegator_delegated,
    uint256 boost_tokens_extend_token_id_data,address VOTING_ESCROW
) external view returns (VotingEscrowDelegation.Point memory);
function token_boost(uint256 _token_id,address VOTING_ESCROW_DELEGATION) external view returns (int256) ;
function token_expiry(uint256 _token_id,address VOTING_ESCROW_DELEGATION) external view returns (uint256) ;
function token_cancel_time(uint256 _token_id,address VOTING_ESCROW_DELEGATION) external view returns (uint256) ;


}

// interface ERC20 {
//     function balanceOf(address _owner) external view returns (uint256);
//     function transfer(address _to, uint256 _value) external returns (bool);
//     function allowance(address _owner, address _spender) external view returns (uint256);
//     function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
// }

contract Delegation{
  event CommitAdmins(address ownership_admin, address emergency_admin);
  
  event ApplyAdmins(address ownership_admin, address emergency_admin);

  
  event DelegationSet(address delegation);
  event Approval(
    address _owner,
    address _approved,
    uint256 _token_id
);




// event ApprovalForAll:
//     _owner: indexed(address)
//     _operator: indexed(address)
//     _approved: bool

event ApprovalForAll(
    address _owner,
    address _operator,
    bool _approved
);

// event Transfer:
//     _from: indexed(address)
//     _to: indexed(address)
//     _token_id: indexed(uint256)

event Transfer(
    address _from,
    address _to,
    uint256 _token_id
);

// event BurnBoost:
//     _delegator: indexed(address)
//     _receiver: indexed(address)
//     _token_id: indexed(uint256)

event BurnBoost(
    address _delegator,
    address _receiver,
    uint256 _token_id
);

// event DelegateBoost:
//     _delegator: indexed(address)
//     _receiver: indexed(address)
//     _token_id: indexed(uint256)
//     _amount: uint256
//     _cancel_time: uint256
//     _expire_time: uint256

event DelegateBoost(
    address _delegator,
    address _receiver,
    uint256 _token_id,
    uint256 _amount,
    uint256 _cancel_time,
    uint256 _expire_time
);

// event ExtendBoost:
//     _delegator: indexed(address)
//     _receiver: indexed(address)
//     _token_id: indexed(uint256)
//     _amount: uint256
//     _expire_time: uint256
//     _cancel_time: uint256

event ExtendBoost(
    address _delegator,
    address _receiver,
    uint256 _token_id,
    uint256 _amount,
    uint256 _expire_time,
    uint256 _cancel_time
);

// event TransferBoost:
//     _from: indexed(address)
//     _to: indexed(address)
//     _token_id: indexed(uint256)
//     _amount: uint256
//     _expire_time: uint256

event TransferBoost(
    address _from,
    address _to,
    uint256 _token_id,
    uint256 _amount,
    uint256 _expire_time
);

// event GreyListUpdated:
//     _receiver: indexed(address)
//     _delegator: indexed(address)
//     _status: bool

event GreyListUpdated(
    address _receiver,
    address _delegator,
    bool _status
);
uint256 constant MAX_PCT = 10_000;
uint256 constant WEEK = 86400 * 7;
// address constant VOTING_ESCROW = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2;
// address constant VOTING_ESCROW_DELEGATION = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2;
uint256 constant MAX_UINT256 = 2**256 - 1;
address constant public ZERO_ADDRESS = address(0);
  mapping(address => uint256) public balanceOf;
  mapping(uint256 => address) public getApproved;
  mapping(address => mapping(address => bool)) public isApprovedForAll;
  mapping(uint256 => address) public ownerOf;

  // mapping(uint256 => address) public getApproved;
  // mapping(address => mapping(address => bool)) public isApprovedForAll;


  // using the address of VotingEscrow's smart contract deployed on ganache for now. Will have to change once contract is actually deployed

// this is the contract of votingescrow contract

// change this according voting escrow deployment
  address immutable VOTING_ESCROW;
  address public utils;


// can set the address of the votingescrow delegation contract
  address public delegation;


  address public emergency_admin; 
  address public ownership_admin; 
  address public future_emergency_admin; 
  address public future_ownership_admin;
  string public base_uri;


  function getOwnershipAdmin() public view returns (address) {
    return ownership_admin;
  }

  function getEmergencyAdmin() public view returns (address) {
    return emergency_admin;
  }

  function getDelegation() public view returns (address) {
    return delegation;
  }

  function approve(address _approved, uint256 _token_id) public {
    address owner = ownerOf[_token_id];
    require(msg.sender == owner || isApprovedForAll[owner][msg.sender],"must be owner or operator");
    getApproved[_token_id] = _approved;
    emit Approval(owner, _approved, _token_id);
}

function approve(address _owner , address _approved, uint256 _token_id) public {
    getApproved[_token_id] = _approved;
    emit Approval(_owner, _approved, _token_id);
}



  constructor (address _delegation, address _o_admin,address _e_admin,string memory _base_uri,address _voting_escrow,address _utils) {

    VOTING_ESCROW = _voting_escrow;
    delegation = _delegation;

    ownership_admin = _o_admin;
    emergency_admin = _e_admin;

    base_uri = _base_uri;
    utils = _utils;

    emit DelegationSet(_delegation);
  }

function tokenURI(uint256 _token_id) internal view returns (string memory) {
    return Utilsde(utils).concat(base_uri,Utilsde(utils)._uint_to_string(_token_id));
}

function mint(address _to , uint256 _token_id) public {
    require(_to != ZERO_ADDRESS,"0");
    require (ownerOf[_token_id] == ZERO_ADDRESS,"1"); // dev: token exists


    // minting - This is called before updates to balance and totalSupply
    VotingEscrowDelegation(delegation).update_enumeration_data(ZERO_ADDRESS, _to, _token_id,0,balanceOf[_to]);
    balanceOf[_to] += 1;
    ownerOf[_token_id] = _to;
    emit Transfer(ZERO_ADDRESS, _to, _token_id);
}



function getbalance(address _owner) public view returns (uint256) {
    return balanceOf[_owner];
}

function burn(uint256 _token_id) public {
    address owner = ownerOf[_token_id];

    approve(owner, ZERO_ADDRESS, _token_id);

    balanceOf[owner] -= 1;
    ownerOf[_token_id] = ZERO_ADDRESS;
    

    VeDelegation(delegation).update_enumeration_data(owner, ZERO_ADDRESS, _token_id,balanceOf[owner],0);
    emit Transfer(msg.sender, ZERO_ADDRESS, _token_id);
    Utilsde(utils)._is_approved_or_owner(msg.sender,ownerOf[_token_id],getApproved[_token_id],isApprovedForAll[ownerOf[_token_id]][msg.sender]);
    uint256 tdata = VeDelegation(delegation).get_boost_token_data(_token_id);
    if (tdata != 0) {
        address delegator = address(uint160(Utilsde(utils).shift(_token_id, -96)));
        VeDelegation(delegation)._burn_boost(_token_id, delegator, owner);
        emit BurnBoost(delegator, owner, _token_id);
    }
    VeDelegation(delegation).update_enumeration_data(ownerOf[_token_id], ZERO_ADDRESS, _token_id,balanceOf[owner],0);
}

function transfer(address _from,address _to,uint256 _token_id) public {
    Utilsde(utils)._is_approved_or_owner(msg.sender,ownerOf[_token_id],getApproved[_token_id],isApprovedForAll[ownerOf[_token_id]][msg.sender]);
    require(_to != ZERO_ADDRESS);
    require(ownerOf[_token_id] == _from,"_from is not owner");

    address delegator = address(uint160(Utilsde(utils).shift(_token_id, -96)));
    VeDelegation(delegation).transfer_boost_permission(_to, delegator);

    // clear previous token approval
    approve(_from, ZERO_ADDRESS, _token_id);

    balanceOf[_from] -= 1;
    VeDelegation(delegation).update_enumeration_data(_from, _to, _token_id,balanceOf[_from],balanceOf[_to]);
    balanceOf[_to] += 1;
    ownerOf[_token_id] = _to;

    VotingEscrowDelegation.Point memory tpoint = Utilsde(utils)._deconstruct_bias_slope(VeDelegation(delegation).get_boost_token_data(_token_id));
    int256 tvalue = tpoint.slope * Utilsde(utils).uinttoint(block.timestamp) + tpoint.bias;

    // if the boost value is negative, reset the slope and bias
    if (tvalue > 0) {
        VeDelegation(delegation)._transfer_boost(_from, _to, tpoint.bias, tpoint.slope);
        // y = mx + b -> y - b = mx -> (y - b)/m = x -> -b / m = x (x-intercept)
        uint256 expiry = Utilsde(utils).inttouint(-tpoint.bias / tpoint.slope);
        emit TransferBoost(_from, _to, _token_id, Utilsde(utils).inttouint(tvalue), expiry);
    } else {
        VeDelegation(delegation)._burn_boost(_token_id, delegator, _from);
        emit BurnBoost(delegator, _from, _token_id);
    }
    
    emit Transfer(_from, _to, _token_id);
}

function cancel_boost(uint256 _token_id,address _caller) public {
  address delegator = address(uint160(Utilsde(utils).shift(_token_id, -96)));
  address receiver = ownerOf[_token_id];
  VotingEscrowDelegation.Point memory tpoint = Utilsde(utils)._deconstruct_bias_slope(VeDelegation(delegation).get_boost_token_data(_token_id));
    require(receiver != ZERO_ADDRESS,"token does not exist");
    int256 tvalue = tpoint.slope * Utilsde(utils).uinttoint(block.timestamp) + tpoint.bias;
    require(_caller == receiver || isApprovedForAll[receiver][_caller] || tvalue <= 0);
    VeDelegation(delegation)._burn_boost(_token_id, delegator, receiver);
    emit BurnBoost(delegator, delegator, _token_id);
}

function safeTransferFrom(address _from , address _to , uint256 _token_id , bytes memory _data) public  {

    //     @notice Transfers the ownership of an NFT from one address to another address
    //     @dev Throws unless `msg.sender` is the current owner, an authorized
    //         operator, or the approved address for this NFT. Throws if `_from` is
    //         not the current owner. Throws if `_to` is the zero address. Throws if
    //         `_tokenId` is not a valid NFT. When transfer is complete, this function
    //         checks if `_to` is a smart contract (code size > 0). If so, it calls
    //         `onERC721Received` on `_to` and throws if the return value is not
    //         `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    //     @param _from The current owner of the NFT
    //     @param _to The new owner
    //     @param _token_id The NFT to transfer
    //     @param _data Additional data with no specified format, sent in call to `_to`, max length 4096

    transfer(_from, _to, _token_id);

    if (Utilsde(utils).is_contract(_to)) {
        bytes32 response = ERC721Receiver(_to).onERC721Received(
            msg.sender, _from, _token_id, _data
        );
        bytes4 y = bytes4(0);
        assembly {
            mstore(y,response)
        }
        require(y == keccak256("onERC721Received(address,address,uint256,bytes)"),"invalid response");
    }
}

function setApproveForAll(address _operator,bool _approved) public {
    //     @notice Enable or disable approval for a third party ("operator") to manage
    //         all of `msg.sender`'s assets.
    //     @dev Emits the ApprovalForAll event. Multiple operators per account are allowed.
    //     @param _operator Address to add to the set of authorized operators.
    //     @param _approved True if the operator is approved, false to revoke approval.
    isApprovedForAll[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
}



function getowner(uint256 _token_id) public view returns(address){
    return ownerOf[_token_id];
}


  function adjusted_balance_of(address _account) public view returns (uint256) {
    if (delegation == ZERO_ADDRESS) {
      return ERC20(VOTING_ESCROW).balanceOf(_account);
    }

    return VotingEscrowDelegation(delegation).adjusted_balance_of(_account);
  }



  function kill_delegation() public {

    require(msg.sender == ownership_admin || msg.sender == emergency_admin);

    delegation = ZERO_ADDRESS;
    emit DelegationSet(ZERO_ADDRESS);
  }


  function __set_delegation(address _delegation) public {
    require(msg.sender == ownership_admin);

    // call `adjusted_balance_of` to make sure it works
    VeDelegation(_delegation).adjusted_balance_of(msg.sender);

    delegation = _delegation;
    emit DelegationSet(_delegation);
  }



  function commit_set_admins(address  _o_admin,address  _e_admin) public {
    require(msg.sender == ownership_admin);

    future_ownership_admin = _o_admin;
    future_emergency_admin = _e_admin;

    emit CommitAdmins(_o_admin, _e_admin);
  }


  function apply_set_admins() public {
    address _o_admin = future_ownership_admin;
    address _e_admin = future_emergency_admin;

    require(msg.sender == ownership_admin);

    ownership_admin = _o_admin;
    emergency_admin = _e_admin;

    emit ApplyAdmins(_o_admin, _e_admin);
  }

  function cancel_boost(uint256 _token_id) public {
    //     @notice Cancel an outstanding boost
    //     @dev This does not burn the token, only the boost it represents. The owner
    //         of the token or their operator can cancel a boost at any time. The
    //         delegator or their operator can only cancel a token after the cancel
    //         time. Anyone can cancel the boost if the value of it is negative.
    //     @param _token_id The token to cancel
    VeDelegation(delegation).cancel_boost(_token_id, msg.sender);
}

function batch_cancel_boosts(uint256[] memory _token_ids) public {
    //     @notice Cancel many outstanding boosts
    //     @dev This does not burn the token, only the boost it represents. The owner
    //         of the token or their operator can cancel a boost at any time. The
    //         delegator or their operator can only cancel a token after the cancel
    //         time. Anyone can cancel the boost if the value of it is negative.
    //     @param _token_ids A list of 256 token ids to nullify. The list must
    //         be padded with 0 values if less than 256 token ids are provided.
    for (uint256 index = 0; index < _token_ids.length; index++) {
        uint256 _token_id = _token_ids[index];
        if (_token_id == 0) {
            break;
        }
        cancel_boost(_token_id, msg.sender);
    }
}

function create_boost(
    address _delegator,
    address _receiver,
    int256 _percentage,
    uint256 _cancel_time,
    uint256 _expire_time,
    uint256 _id
) public {
  require(_delegator != address(0),"0");
  require(msg.sender == _delegator || isApprovedForAll[_delegator][msg.sender],"d or o");  // dev: only delegator or operator
  uint256 token_id = Utilsde(utils).shift((uint160(_delegator)), 96) + _id;
  mint(_receiver, token_id);
  VotingEscrowDelegation(delegation).create_boost(_delegator, _receiver, _percentage, _cancel_time, _expire_time, _id);
  
    // check if the token exists here before we expend more gas by minting it
  // VeDelegation(delegation).update_enumeration_data(ZERO_ADDRESS,_receiver, token_id,0,balanceOf[_receiver]);
  
}

function debugger(address _id) public view {
     VotingEscrowDelegation(delegation).debugger(_id);
}

function extend_boost(uint256 _token_id , int256 _percentage , uint256 _expiry_time ,uint256 _cancel_time) public {
  address delegator = address(uint160(Utilsde(utils).shift(_token_id, -96)));
  address receiver = ownerOf[_token_id];
    
    require(msg.sender == delegator || isApprovedForAll[delegator][msg.sender]); // dev: only delegator or operator
    
    VeDelegation(delegation).extend_boost(_token_id, _percentage, _expiry_time, _cancel_time,receiver);
    VeDelegation(delegation)._burn_boost(_token_id, delegator, receiver);
    
}


function set_delegation_status(address _reciever , address _delegator , bool _status) public {
    //     @notice Set or reaffirm the blacklist/whitelist status of a delegator for a receiver.
    //     @dev Setting delegator as the Utilsde(utils).ZERO_ADDRESS enables users to deactive delegations globally
    //         and enable the white list. The ability of a delegator to delegate to a receiver
    //         is determined by ~(grey_list[_receiver][Utilsde(utils).ZERO_ADDRESS] ^ grey_list[_receiver][_delegator]).
    //     @param _receiver The account which we will be updating it's list
    //     @param _delegator The account to disallow/allow delegations from
    //     @param _status Boolean of the status to set the _delegator account to
    require(msg.sender == _reciever || isApprovedForAll[_reciever][ msg.sender], "only the owner or approved can set the status");
    VeDelegation(delegation)._set_delegation_status(_reciever, _delegator, _status);
}

function batch_set_delegation_status(address _reciever,address[] memory _delegators , uint256[] memory _status) public {
    //     @notice Set or reaffirm the blacklist/whitelist status of multiple delegators for a receiver.
    //     @dev Setting delegator as the Utilsde(utils).ZERO_ADDRESS enables users to deactive delegations globally
    //         and enable the white list. The ability of a delegator to delegate to a receiver
    //         is determined by ~(grey_list[_receiver][Utilsde(utils).ZERO_ADDRESS] ^ grey_list[_receiver][_delegator]).
    //     @param _receiver The account which we will be updating it's list
    //     @param _delegators List of 256 accounts to disallow/allow delegations from
    //     @param _status List of 256 0s and 1s (booleans) of the status to set the _delegator_i account to.
    //         if the value is not 0 or 1, execution will break, effectively stopping at the index.
    require(msg.sender == _reciever || isApprovedForAll[_reciever][msg.sender], "only the owner or approved can set the status");

    for (uint256 i = 0; i < _delegators.length; i++) {
        if (_status[i] > 1) {
            break;
        }
        VeDelegation(delegation)._set_delegation_status(_reciever, _delegators[i], (_status[i] != 0));
    }
}




}
