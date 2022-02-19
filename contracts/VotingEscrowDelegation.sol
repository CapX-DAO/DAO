// # @version 0.2.15
// """
// @title Voting Escrow Delegation
// @author Curve Finance
// @license MIT
// @dev Provides test functions only available in test mode (`brownie test`)
// """
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


// interface ERC721Receiver:
//     def onERC721Received(
//         _operator: address, _from: address, _token_id: uint256, _data: Bytes[4096]
//     ) -> bytes32:
//         nonpayable

import {Utils} from "../dependencies/open-zeppelin/Utils.sol";

interface VE {
    function balanceOf(address _account) external view returns (uint256);
    function locked__end(address _addr) external view returns (uint256);
}

interface Utilsdel {
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
function adjusted_balance_of(address _account, VotingEscrowDelegation.Boost memory boost_account,address VOTING_ESCROW) external view returns (uint256);
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


import {SafeCast} from '../dependencies/open-zeppelin/SafeCast.sol';


contract VotingEscrowDelegation {

    address constant public ZERO_ADDRESS = address(0);
    uint256 constant MAX_PCT = 10_000;
uint256 constant WEEK = 86400 * 7;
// address constant VOTING_ESCROW = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2;
// address constant VOTING_ESCROW_DELEGATION = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2;
uint256 constant MAX_UINT256 = 2**256 - 1;

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


    struct Boost {
    // [bias uint128][slope int128]
    uint256 delegated;
    uint256 received;
    // [total active delegations 128][next expiry 128]
    uint256 expiry_data;
}

// struct Token:
//     # [bias uint128][slope int128]
//     data: uint256
//     # [delegator pos 128][cancel time 128]
//     dinfo: uint256
//     # [global 128][local 128]
//     position: uint256
//     expire_time: uint256

struct Token {
    // [bias uint128][slope int128]
    uint256 data;
    // [delegator pos 128][cancel time 128]
    uint256 dinfo;
    // [global 128][local 128]
    uint256 position;
    uint256 expire_time;
}

// struct Point:
//     bias: int256
//     slope: int256

struct Point {
    int256 bias;
    int256 slope;
}



// struct Boost:
//     # [bias uint128][slope int128]
//     delegated: uint256
//     received: uint256
//     # [total active delegations 128][next expiry 128]
//     expiry_data: uint256

    
// IDENTITY_PRECOMPILE: constant(address) = 0x0000000000000000000000000000000000000004
// MAX_PCT: constant(uint256) = 10_000
// WEEK: constant(uint256) = 86400 * 7
// VOTING_ESCROW: constant(address) = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2

address public VOTING_ESCROW;
address public utils;



// balanceOf: public(HashMap[address, uint256])
// getApproved: public(HashMap[uint256, address])
// isApprovedForAll: public(HashMap[address, HashMap[address, bool]])
// ownerOf: public(HashMap[uint256, address])



// name: public(String[32])
// symbol: public(String[32])
// base_uri: public(String[128])

string public name;
string public symbol;
string public base_uri;

// totalSupply: public(uint256)
// # use totalSupply to determine the length
// tokenByIndex: public(HashMap[uint256, uint256])
// # use balanceOf to determine the length
// tokenOfOwnerByIndex: public(HashMap[address, uint256[MAX_UINT256]])

uint256 public totalSupply;
// use totalSupply to determine the length
mapping(uint256 => uint256) public tokenByIndex;
// use balanceOf to determine the length
mapping(address => mapping(uint256 => uint256)) public tokenOfOwnerByIndex;

mapping(address => Boost) public boost;
mapping(uint256 => Token) public boost_tokens;

// boost: HashMap[address, Boost]
// boost_tokens: HashMap[uint256, Token]



// token_of_delegator_by_index: public(HashMap[address, uint256[MAX_UINT256]])
// total_minted: public(HashMap[address, uint256])
// # address => timestamp => # of delegations expiring
// account_expiries: public(HashMap[address, HashMap[uint256, uint256]])

mapping(address => mapping(uint256 => uint256)) public token_of_delegator_by_index;
mapping(address => uint256) public total_minted;
// address => timestamp => # of delegations expiring
mapping(address => mapping(uint256 => uint256)) public account_expiries;

// admin: public(address)  # Can and will be a smart contract
// future_admin: public(address)

address public admin; // Can and will be a smart contract
address public future_admin;

// # The grey list - per-user black and white lists
// # users can make this a blacklist or a whitelist - defaults to blacklist
// # gray_list[_receiver][_delegator]
// # by default is blacklist, with no delegators blacklisted
// # if [_receiver][ZERO_ADDRESS] is False = Blacklist, True = Whitelist
// # if this is a blacklist, receivers disallow any delegations from _delegator if it is True
// # if this is a whitelist, receivers only allow delegations from _delegator if it is True
// # Delegation will go through if: not (grey_list[_receiver][ZERO_ADDRESS] ^ grey_list[_receiver][_delegator])
// grey_list: public(HashMap[address, HashMap[address, bool]])

// The grey list - per-user black and white lists
// users can make this a blacklist or a whitelist - defaults to blacklist
// gray_list[_receiver][_delegator]
// by default is blacklist, with no delegators blacklisted
// if [_receiver][ZERO_ADDRESS] is False = Blacklist, True = Whitelist
// if this is a blacklist, receivers disallow any delegations from _delegator if it is True
// if this is a whitelist, receivers only allow delegations from _delegator if it is True
// Delegation will go through if: not (grey_list[_receiver][ZERO_ADDRESS] ^ grey_list[_receiver][_delegator])
mapping(address => mapping(address => bool)) public grey_list;

function get_boost_token_data(uint256 _token_id) public view returns (uint256) {
    return boost_tokens[_token_id].data;
}

function transfer_boost_permission(address _to , address delegator) internal view {
    uint256 is_whitelist = (grey_list[_to][ZERO_ADDRESS] ? 1 : 0);
    uint256 delegator_status = (grey_list[_to][delegator] ? 1 : 0);
    require(((is_whitelist ^ delegator_status) == 0),"transfer boost not allowed");
}

function get_boost_token_dinfo(uint256 _token_id) public view returns (uint256) {
    return boost_tokens[_token_id].dinfo;
}
// @external
// def commit_transfer_ownership(_addr: address):
//     """
//     @notice Transfer ownership of contract to `addr`
//     @param _addr Address to have ownership transferred to
//     """
//     assert msg.sender == self.admin  # dev: admin only
//     self.future_admin = _addr

function commit_transfer_ownership(address _addr) public {
    //     @notice Transfer ownership of contract to `addr`
    //     @param _addr Address to have ownership transferred to
    require(msg.sender == admin, "admin only");
    future_admin = _addr;
}

// @external
// def accept_transfer_ownership():
//     """
//     @notice Accept admin role, only callable by future admin
//     """
//     future_admin: address = self.future_admin
//     assert msg.sender == future_admin
//     self.admin = future_admin

function accept_transfer_ownership() public {
    //     @notice Accept admin role, only callable by future admin
    //     @dev Only callable by future admin
    require(msg.sender == future_admin, "future admin only");
    admin = future_admin;
}




// @external
// def set_base_uri(_base_uri: String[128]):
//     assert msg.sender == self.admin
//     self.base_uri = _base_uri

function set_base_uri(string memory _base_uri) public {
    //     @notice Set the base URI for the contract
    //     @param _base_uri The base URI for the contract
    
    require(msg.sender == admin, "admin only");
    base_uri = _base_uri;
}

    

// @external
// def __init__(_name: String[32], _symbol: String[32], _base_uri: String[128]):
//     self.name = _name
//     self.symbol = _symbol
//     self.base_uri = _base_uri

//     self.admin = msg.sender

constructor(string memory _name, string memory _symbol, string memory _base_uri,address _VOTING_ESCROW,address _utils) {
    name = _name;
    symbol = _symbol;
    base_uri = _base_uri;
    VOTING_ESCROW = _VOTING_ESCROW;
    utils = _utils;


    admin = msg.sender;

}


// @external
// def _approve(_owner: address, _approved: address, _token_id: uint256):
//     self.getApproved[_token_id] = _approved
//     log Approval(_owner, _approved, _token_id)



// @view
// @external
// def _is_approved_or_owner(_spender: address, _token_id: uint256) -> bool:
//     owner: address = self.ownerOf[_token_id]
//     return (
//         _spender == owner
//         or _spender == self.getApproved[_token_id]
//         or self.isApprovedForAll[owner][_spender]
//     )


// @external
// def update_enumeration_data(_from: address, _to: address, _token_id: uint256):
//     delegator: address = convert(Utilsdel(utils).shift(_token_id, -96), address)
//     position_data: uint256 = self.boost_tokens[_token_id].position
//     local_pos: uint256 = position_data % 2 ** 128
//     global_pos: uint256 = Utilsdel(utils).shift(position_data, -128)
//     # position in the delegator array of minted tokens
//     delegator_pos: uint256 = Utilsdel(utils).shift(self.boost_tokens[_token_id].dinfo, -128)

//     if _from == Utilsdel(utils).ZERO_ADDRESS:
//         # minting - This is called before updates to balance and totalSupply
//         local_pos = self.balanceOf[_to]
//         global_pos = self.totalSupply
//         position_data = Utilsdel(utils).shift(global_pos, 128) + local_pos
//         # this is a new token so we get the index of a new spot
//         delegator_pos = self.total_minted[delegator]

//         self.tokenByIndex[global_pos] = _token_id
//         self.tokenOfOwnerByIndex[_to][local_pos] = _token_id
//         self.boost_tokens[_token_id].position = position_data

//         # we only mint tokens in the create_boost fn, and this is called
//         # before we update the cancel_time so we can just set the value
//         # of dinfo to the shifted position
//         self.boost_tokens[_token_id].dinfo = Utilsdel(utils).shift(delegator_pos, 128)
//         self.token_of_delegator_by_index[delegator][delegator_pos] = _token_id
//         self.total_minted[delegator] = delegator_pos + 1

//     elif _to == Utilsdel(utils).ZERO_ADDRESS:
//         # burning - This is called after updates to balance and totalSupply
//         # we operate on both the global array and local array
//         last_global_index: uint256 = self.totalSupply
//         last_local_index: uint256 = self.balanceOf[_from]
//         last_delegator_pos: uint256 = self.total_minted[delegator] - 1

//         if global_pos != last_global_index:
//             # swap - set the token we're burnings position to the token in the last index
//             last_global_token: uint256 = self.tokenByIndex[last_global_index]
//             last_global_token_pos: uint256 = self.boost_tokens[last_global_token].position
//             # update the global position of the last global token
//             self.boost_tokens[last_global_token].position = Utilsdel(utils).shift(global_pos, 128) + (last_global_token_pos % 2 ** 128)
//             self.tokenByIndex[global_pos] = last_global_token
//         self.tokenByIndex[last_global_index] = 0

//         if local_pos != last_local_index:
//             # swap - set the token we're burnings position to the token in the last index
//             last_local_token: uint256 = self.tokenOfOwnerByIndex[_from][last_local_index]
//             last_local_token_pos: uint256 = self.boost_tokens[last_local_token].position
//             # update the local position of the last local token
//             self.boost_tokens[last_local_token].position = Utilsdel(utils).shift(last_local_token_pos / 2 ** 128, 128) + local_pos
//             self.tokenOfOwnerByIndex[_from][local_pos] = last_local_token
//         self.tokenOfOwnerByIndex[_from][last_local_index] = 0
//         self.boost_tokens[_token_id].position = 0

//         if delegator_pos != last_delegator_pos:
//             last_delegator_token: uint256 = self.token_of_delegator_by_index[delegator][last_delegator_pos]
//             last_delegator_token_dinfo: uint256 = self.boost_tokens[last_delegator_token].dinfo
//             # update the last tokens position data and maintain the correct cancel time
//             self.boost_tokens[last_delegator_token].dinfo = Utilsdel(utils).shift(delegator_pos, 128) + (last_delegator_token_dinfo % 2 ** 128)
//             self.token_of_delegator_by_index[delegator][delegator_pos] = last_delegator_token
//         self.token_of_delegator_by_index[delegator][last_delegator_pos] = 0
//         self.boost_tokens[_token_id].dinfo = 0  # we are burning the token so we can just set to 0
//         self.total_minted[delegator] = last_delegator_pos

//     else:
//         # transfering - called between balance updates
//         from_last_index: uint256 = self.balanceOf[_from]

//         if local_pos != from_last_index:
//             # swap - set the token we're burnings position to the token in the last index
//             last_local_token: uint256 = self.tokenOfOwnerByIndex[_from][from_last_index]
//             last_local_token_pos: uint256 = self.boost_tokens[last_local_token].position
//             # update the local position of the last local token
//             self.boost_tokens[last_local_token].position = Utilsdel(utils).shift(last_local_token_pos / 2 ** 128, 128) + local_pos
//             self.tokenOfOwnerByIndex[_from][local_pos] = last_local_token
//         self.tokenOfOwnerByIndex[_from][from_last_index] = 0

//         # to is simple we just add to the end of the list
//         local_pos = self.balanceOf[_to]
//         self.tokenOfOwnerByIndex[_to][local_pos] = _token_id
//         self.boost_tokens[_token_id].position = Utilsdel(utils).shift(global_pos, 128) + local_pos

function debugger(address _delegator) public view returns(Point memory) {
    return Utilsdel(utils)._deconstruct_bias_slope(boost[_delegator].delegated);
}


function update_enumeration_data(address _from,address _to,uint256 _token_id,uint256 balance_of_from,uint256 balance_of_to) external {
        address delegator = address(uint160((Utilsdel(utils).shift(_token_id, (-96)))));
        uint256 position_data = boost_tokens[_token_id].position;
        uint256 local_pos = position_data % 2 ** 128;
        uint256 global_pos = Utilsdel(utils).shift(position_data, -128);
        uint256 delegator_pos = Utilsdel(utils).shift(boost_tokens[_token_id].dinfo, -128);


        if (_from == ZERO_ADDRESS) {
            local_pos = balance_of_to;
            global_pos = totalSupply;
            position_data = Utilsdel(utils).shift(global_pos, 128) + local_pos;
            // // this is a new token so we get the index of a new spot
            delegator_pos = total_minted[delegator];

            tokenByIndex[global_pos] = _token_id;
            tokenOfOwnerByIndex[_to][local_pos] = _token_id;
            boost_tokens[_token_id].position = position_data;

            // we only mint tokens in the create_boost fn, and this is called
            // before we update the cancel_time so we can just set the value
            // of dinfo to the shifted position
            boost_tokens[_token_id].dinfo = Utilsdel(utils).shift(delegator_pos, 128) + (delegator_pos % 2 ** 128);
            token_of_delegator_by_index[delegator][delegator_pos] = _token_id;
            total_minted[delegator] = delegator_pos + 1;

            
            totalSupply += 1;
        } else if (_to == ZERO_ADDRESS) {
            

            // burning - This is called after updates to balance and totalSupply
            // we operate on both the global array and local array
            uint256 last_global_index = totalSupply;
            uint256 last_delegator_pos = total_minted[delegator] - 1;

            if (global_pos != last_global_index) {
                // swap - set the token we're burnings position to the token in the last index
                uint256 last_global_token = tokenByIndex[last_global_index];
                uint256 last_global_token_pos = boost_tokens[last_global_token].position;
                // update the global position of the last global token
                boost_tokens[last_global_token].position = Utilsdel(utils).shift(global_pos, 128) + (last_global_token_pos % 2 ** 128);
                tokenByIndex[global_pos] = last_global_token;
                
            }
            tokenByIndex[last_global_index] = 0;

            if (local_pos != balance_of_from) {
                // swap - set the token we're burnings position to the token in the last index
                uint256 last_local_token = tokenOfOwnerByIndex[_from][balance_of_from];
                // uint256 last_local_token_pos = ;
                // update the local position of the last local token
                boost_tokens[last_local_token].position = Utilsdel(utils).shift(boost_tokens[last_local_token].position / 2 ** 128, 128) + local_pos;
                tokenOfOwnerByIndex[_from][local_pos] = last_local_token;
            }
            tokenOfOwnerByIndex[_from][balance_of_from] = 0;
            boost_tokens[_token_id].position = 0;

            if (delegator_pos != last_delegator_pos) {
                uint256 last_delegator_token = token_of_delegator_by_index[delegator][last_delegator_pos];
                uint256 last_delegator_token_dinfo = boost_tokens[last_delegator_token].dinfo;
                // update the last tokens position data and maintain the correct cancel time
                boost_tokens[last_delegator_token].dinfo = Utilsdel(utils).shift(delegator_pos, 128) + (last_delegator_token_dinfo % 2 ** 128);
                token_of_delegator_by_index[delegator][delegator_pos] = last_delegator_token;
            }
            token_of_delegator_by_index[delegator][last_delegator_pos] = 0;
            boost_tokens[_token_id].dinfo = 0;  // we are burning the token so we can just set to 0
            total_minted[delegator] = last_delegator_pos;
            totalSupply -= 1;
            

        }

        else {
            // transfering - called between balance updates

            if (local_pos != balance_of_from) {
                // swap - set the token we're burnings position to the token in the last index
                uint256 last_local_token = tokenOfOwnerByIndex[_from][balance_of_from];
                uint256 last_local_token_pos = boost_tokens[last_local_token].position;
                // update the local position of the last local token
                boost_tokens[last_local_token].position = Utilsdel(utils).shift(last_local_token_pos / 2 ** 128, 128) + local_pos;
                tokenOfOwnerByIndex[_from][local_pos] = last_local_token;
            }
            tokenOfOwnerByIndex[_from][balance_of_from] = 0;

            // to is simple we just add to the end of the list
            local_pos = balance_of_to;
            tokenOfOwnerByIndex[_to][local_pos] = _token_id;
            boost_tokens[_token_id].position = Utilsdel(utils).shift(global_pos, 128) + local_pos;
        }
        

        
}


// @external
// def _burn(_token_id: uint256):
//     owner: address = self.ownerOf[_token_id]

//     self._approve(owner, Utilsdel(utils).ZERO_ADDRESS, _token_id)

//     self.balanceOf[owner] -= 1
//     self.ownerOf[_token_id] = Utilsdel(utils).ZERO_ADDRESS
//     self.totalSupply -= 1

//     self.update_enumeration_data(owner, Utilsdel(utils).ZERO_ADDRESS, _token_id)

//     log Transfer(owner, Utilsdel(utils).ZERO_ADDRESS, _token_id)

// BURNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
// function _burn(uint256 _token_id) private {
//     address owner = ownerOf[_token_id];

//     _approve(owner, Utilsdel(utils).ZERO_ADDRESS, _token_id);

//     balanceOf[owner] -= 1;
//     ownerOf[_token_id] = Utilsdel(utils).ZERO_ADDRESS;
//     totalSupply -= 1;

//     update_enumeration_data(owner, Utilsdel(utils).ZERO_ADDRESS, _token_id);

//     emit Transfer(owner, Utilsdel(utils).ZERO_ADDRESS, _token_id);
// }


// @external
// def _mint(_to: address, _token_id: uint256):
//     assert _to != Utilsdel(utils).ZERO_ADDRESS  # dev: minting to Utilsdel(utils).ZERO_ADDRESS disallowed
//     assert self.ownerOf[_token_id] == Utilsdel(utils).ZERO_ADDRESS  # dev: token exists

//     self.update_enumeration_data(Utilsdel(utils).ZERO_ADDRESS, _to, _token_id)

//     self.balanceOf[_to] += 1
//     self.ownerOf[_token_id] = _to
//     self.totalSupply += 1

//     log Transfer(Utilsdel(utils).ZERO_ADDRESS, _to, _token_id)



// @external
// def _mint_boost(_token_id: uint256, _delegator: address, _receiver: address, _bias: int256, _slope: int256, _cancel_time: uint256, _expire_time: uint256):
//     is_whitelist: uint256 = convert(self.grey_list[_receiver][Utilsdel(utils).ZERO_ADDRESS], uint256)
//     delegator_status: uint256 = convert(self.grey_list[_receiver][_delegator], uint256)
//     assert not convert(bitwise_xor(is_whitelist, delegator_status), bool)  # dev: mint boost not allowed

//     data: uint256 = Utilsdel(utils).shift(convert(_bias, uint256), 128) + convert(Utilsdel(utils).abs(_slope), uint256)
//     self.boost[_delegator].delegated += data
//     self.boost[_receiver].received += data

//     token: Token = self.boost_tokens[_token_id]
//     token.data = data
//     token.dinfo = token.dinfo + _cancel_time
//     token.expire_time = _expire_time
//     self.boost_tokens[_token_id] = token

function _mint_boost(uint256 _token_id,address _delegator,address _receiver,Point memory point,uint256 _cancel_time,uint256 _expire_time) private {
    // uint256 is_whitelist = (grey_list[_receiver][Utilsdel(utils).ZERO_ADDRESS] ? 1 : 0);
    // uint256 delegator_status = (grey_list[_receiver][_delegator] ? 1 : 0);
    require ((((grey_list[_receiver][ZERO_ADDRESS] ? 1 : 0) ^ (grey_list[_receiver][_delegator] ? 1 : 0))== 0)); // dev: mint boost not allowed

    uint256 data = Utilsdel(utils).shift(Utilsdel(utils).inttouint(point.bias), 128) + Utilsdel(utils).inttouint(Utilsdel(utils).abs(point.slope));
    boost[_delegator].delegated += data;
    boost[_receiver].received += data;
    boost_tokens[_token_id].data = data;
    boost_tokens[_token_id].dinfo = boost_tokens[_token_id].dinfo + _cancel_time;
    boost_tokens[_token_id].expire_time = _expire_time;
}


// @external
// def _burn_boost(_token_id: uint256, _delegator: address, _receiver: address, _bias: int256, _slope: int256):
//     token: Token = self.boost_tokens[_token_id]
//     expire_time: uint256 = token.expire_time

//     if expire_time == 0:
//         return

//     self.boost[_delegator].delegated -= token.data
//     self.boost[_receiver].received -= token.data

//     token.data = 0
//     # maintain the same position in the delegator array, but remove the cancel time
//     token.dinfo = Utilsdel(utils).shift(token.dinfo / 2 ** 128, 128)
//     token.expire_time = 0
//     self.boost_tokens[_token_id] = token

//     # update the next expiry data
//     expiry_data: uint256 = self.boost[_delegator].expiry_data
//     next_expiry: uint256 = expiry_data % 2 ** 128
//     active_delegations: uint256 = Utilsdel(utils).shift(expiry_data, -128) - 1

//     expiries: uint256 = self.account_expiries[_delegator][expire_time]

//     if active_delegations != 0 and expire_time == next_expiry and expiries == 0:
//         # Will be passed if
//         # active_delegations == 0, no more active boost tokens
//         # or
//         # expire_time != next_expiry, the cancelled boost token isn't the next expiring boost token
//         # or
//         # expiries != 0, the cancelled boost token isn't the only one expiring at expire_time
//         for i in range(1, 513):  # ~10 years
//             # we essentially allow for a boost token be expired for up to 6 years
//             # 10 yrs - 4 yrs (max vecRV lock time) = ~ 6 yrs
//             if i == 512:
//                 raise "Failed to find next expiry"
//             week_ts: uint256 = expire_time + WEEK * (i + 1)
//             if self.account_expiries[_delegator][week_ts] > 0:
//                 next_expiry = week_ts
//                 break
//     elif active_delegations == 0:
//         next_expiry = 0

//     self.boost[_delegator].expiry_data = Utilsdel(utils).shift(active_delegations, 128) + next_expiry
//     self.account_expiries[_delegator][expire_time] = expiries - 1

function _burn_boost(uint256 _token_id,address _delegator,address _receiver) external {
    Token memory token = boost_tokens[_token_id];
    uint256 expire_time = token.expire_time;

    if (expire_time == 0) {
        return;
    }

    boost[_delegator].delegated -= token.data;
    boost[_receiver].received -= token.data;

    token.data = 0;
    token.dinfo = Utilsdel(utils).shift(token.dinfo / 2 ** 128, 128);
    token.expire_time = 0;
    boost_tokens[_token_id] = token;

    // update the next expiry data
    uint256 expiry_data = boost[_delegator].expiry_data;
    uint256 next_expiry = expiry_data % 2 ** 128;
    uint256 active_delegations = Utilsdel(utils).shift(expiry_data, -128) - 1;

    uint256 expiries = account_expiries[_delegator][expire_time];

    if (active_delegations != 0 && expire_time == next_expiry && expiries == 0) {
        // Will be passed if
        // active_delegations == 0, no more active boost tokens
        // or
        // expire_time != next_expiry, the cancelled boost token isn't the next expiring boost token
        // or
        // expiries != 0, the cancelled boost token isn't the only one expiring at expire_time
        for (uint256 i = 1; i < 513; i++) { // ~10 years
            // we essentially allow for a boost token be expired for up to 6 years
            // 10 yrs - 4 yrs (max vecRV lock time) = ~ 6 yrs
            if (i == 512) {
                require(false ,"Failed to find next expiry") ;
            }
            uint256 week_ts = expire_time + WEEK * (i + 1);
            if (account_expiries[_delegator][week_ts] > 0) {
                next_expiry = week_ts;
                break;
            }
        }
    } else if (active_delegations == 0) {
        next_expiry = 0;
    }

    boost[_delegator].expiry_data = Utilsdel(utils).shift(active_delegations, 128) + next_expiry;
    account_expiries[_delegator][expire_time] = expiries - 1;
}


// @external
// def _transfer_boost(_from: address, _to: address, _bias: int256, _slope: int256):
//     data: uint256 = Utilsdel(utils).shift(convert(_bias, uint256), 128) + convert(Utilsdel(utils).abs(_slope), uint256)
//     self.boost[_from].received -= data
//     self.boost[_to].received += data

function _transfer_boost(address _from,address _to,int256 _bias,int256 _slope) external {
    uint256 data = Utilsdel(utils).shift(Utilsdel(utils).inttouint(_bias), 128) + Utilsdel(utils).inttouint(Utilsdel(utils).abs(_slope));
    boost[_from].received -= data;
    boost[_to].received += data;
}


// @pure
// @external
// def Utilsdel(utils)._deconstruct_bias_slope(_data: uint256) -> Point:
//     return Point({bias: convert(Utilsdel(utils).shift(_data, -128), int256), slope: -convert(_data % 2 ** 128, int256)})




// @pure
// @external
// def Utilsdel(utils)._calc_bias_slope(_x: int256, _y: int256, _expire_time: int256) -> Point:
//     # SLOPE: (y2 - y1) / (x2 - x1)
//     # BIAS: y = mx + b -> y - mx = b
//     slope: int256 = -_y / (_expire_time - _x)
//     return Point({bias: _y - slope * _x, slope: slope})




// @external
// def _transfer(_from: address, _to: address, _token_id: uint256):
//     assert self.ownerOf[_token_id] == _from  # dev: _from is not owner
//     assert _to != Utilsdel(utils).ZERO_ADDRESS  # dev: transfers to Utilsdel(utils).ZERO_ADDRESS are disallowed

//     delegator: address = convert(Utilsdel(utils).shift(_token_id, -96), address)
//     is_whitelist: uint256 = convert(self.grey_list[_to][Utilsdel(utils).ZERO_ADDRESS], uint256)
//     delegator_status: uint256 = convert(self.grey_list[_to][delegator], uint256)
//     assert not convert(bitwise_xor(is_whitelist, delegator_status), bool)  # dev: transfer boost not allowed

//     # clear previous token approval
//     self._approve(_from, Utilsdel(utils).ZERO_ADDRESS, _token_id)

//     self.balanceOf[_from] -= 1
//     self.update_enumeration_data(_from, _to, _token_id)
//     self.balanceOf[_to] += 1
//     self.ownerOf[_token_id] = _to

//     tpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(self.boost_tokens[_token_id].data)
//     tvalue: int256 = tpoint.slope * convert(block.timestamp, int256) + tpoint.bias

//     # if the boost value is negative, reset the slope and bias
//     if tvalue > 0:
//         self._transfer_boost(_from, _to, tpoint.bias, tpoint.slope)
//         # y = mx + b -> y - b = mx -> (y - b)/m = x -> -b / m = x (x-intercept)
//         expiry: uint256 = convert(-tpoint.bias / tpoint.slope, uint256)
//         log TransferBoost(_from, _to, _token_id, convert(tvalue, uint256), expiry)
//     else:
//         self._burn_boost(_token_id, delegator, _from, tpoint.bias, tpoint.slope)
//         log BurnBoost(delegator, _from, _token_id)

//     log Transfer(_from, _to, _token_id)




// @external
// def cancel_boost(_token_id: uint256, _caller: address):
//     receiver: address = self.ownerOf[_token_id]
//     assert receiver != Utilsdel(utils).ZERO_ADDRESS  # dev: token does not exist
//     delegator: address = convert(Utilsdel(utils).shift(_token_id, -96), address)

//     token: Token = self.boost_tokens[_token_id]
//     tpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(token.data)
//     tvalue: int256 = tpoint.slope * convert(block.timestamp, int256) + tpoint.bias

//     # if not (the owner or operator or the boost value is negative)
//     if not (_caller == receiver or self.isApprovedForAll[receiver][_caller] or tvalue <= 0):
//         if _caller == delegator or self.isApprovedForAll[delegator][_caller]:
//             # if delegator or operator, wait till after cancel time
//             assert (token.dinfo % 2 ** 128) <= block.timestamp  # dev: must wait for cancel time
//         else:
//             # All others are disallowed
//             raise "Not allowed!"
//     self._burn_boost(_token_id, delegator, receiver, tpoint.bias, tpoint.slope)

//     log BurnBoost(delegator, receiver, _token_id)




// @external
// def _set_delegation_status(_receiver: address, _delegator: address, _status: bool):
//     self.grey_list[_receiver][_delegator] = _status
//     log GreyListUpdated(_receiver, _delegator, _status)

function _set_delegation_status(address _receiver,address _delegator,bool _status) external {
    grey_list[_receiver][_delegator] = _status;
    emit GreyListUpdated(_receiver, _delegator, _status);
}


// @pure
// @external
// def _uint_to_string(_value: uint256) -> String[78]:
//     # NOTE: Odd that this works with a raw_call inside, despite being marked
//     # a pure function
//     if _value == 0:
//         return "0"

//     buffer: Bytes[78] = b""
//     digits: uint256 = 78

//     for i in range(78):
//         # go forward to find the # of digits, and set it
//         # only if we have found the last index
//         if digits == 78 and _value / 10 ** i == 0:
//             digits = i

//         value: uint256 = ((_value / 10 ** (77 - i)) % 10) + 48
//         char: Bytes[1] = slice(convert(value, bytes32), 31, 1)
//         buffer = raw_call(
//             IDENTITY_PRECOMPILE,
//             Utilsdel(utils).concat(buffer, char),
//             max_outsize=78,
//             is_static_call=True
//         )

//     return convert(slice(buffer, 78 - digits, digits), String[78])



// @external
// def approve(_approved: address, _token_id: uint256):
//     """
//     @notice Change or reaffirm the approved address for an NFT.
//     @dev The zero address indicates there is no approved address.
//         Throws unless `msg.sender` is the current NFT owner, or an authorized
//         operator of the current owner.
//     @param _approved The new approved NFT controller.
//     @param _token_id The NFT to approve.
//     """
//     owner: address = self.ownerOf[_token_id]
//     assert (
//         msg.sender == owner or self.isApprovedForAll[owner][msg.sender]
//     )  # dev: must be owner or operator
//     self._approve(owner, _approved, _token_id)



// @external
// def safeTransferFrom(_from: address, _to: address, _token_id: uint256, _data: Bytes[4096] = b""):
//     """
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
//     """
//     assert self._is_approved_or_owner(msg.sender, _token_id)  # dev: neither owner nor approved
//     self._transfer(_from, _to, _token_id)

//     if _to.is_contract:
//         response: bytes32 = ERC721Receiver(_to).onERC721Received(
//             msg.sender, _from, _token_id, _data
//         )
//         assert slice(response, 0, 4) == method_id(
//             "onERC721Received(address,address,uint256,bytes)"
//         )  # dev: invalid response






// @external
// def setApprovalForAll(_operator: address, _approved: bool):
//     """
//     @notice Enable or disable approval for a third party ("operator") to manage
//         all of `msg.sender`'s assets.
//     @dev Emits the ApprovalForAll event. Multiple operators per account are allowed.
//     @param _operator Address to add to the set of authorized operators.
//     @param _approved True if the operator is approved, false to revoke approval.
//     """
//     self.isApprovedForAll[msg.sender][_operator] = _approved
//     log ApprovalForAll(msg.sender, _operator, _approved)




// @external
// def transferFrom(_from: address, _to: address, _token_id: uint256):
//     """
//     @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
//         TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
//         THEY MAY BE PERMANENTLY LOST
//     @dev Throws unless `msg.sender` is the current owner, an authorized
//         operator, or the approved address for this NFT. Throws if `_from` is
//         not the current owner. Throws if `_to` is the Utilsdel(utils).ZERO_ADDRESS.
//     @param _from The current owner of the NFT
//     @param _to The new owner
//     @param _token_id The NFT to transfer
//     """
//     assert self._is_approved_or_owner(msg.sender, _token_id)  # dev: neither owner nor approved
//     self._transfer(_from, _to, _token_id)




// @view
// @external
// def tokenURI(_token_id: uint256) -> String[256]:
//     return Utilsdel(utils).concat(self.base_uri, self._uint_to_string(_token_id))



// @external
// def burn(_token_id: uint256):
//     """
//     @notice Destroy a token
//     @dev Only callable by the token owner, their operator, or an approved account.
//         Burning a token with a currently active boost, burns the boost.
//     @param _token_id The token to burn
//     """
//     assert self._is_approved_or_owner(msg.sender, _token_id)  # dev: neither owner nor approved

//     tdata: uint256 = self.boost_tokens[_token_id].data
//     if tdata != 0:
//         tpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(tdata)

//         delegator: address = convert(Utilsdel(utils).shift(_token_id, -96), address)
//         owner: address = self.ownerOf[_token_id]

//         self._burn_boost(_token_id, delegator, owner, tpoint.bias, tpoint.slope)

//         log BurnBoost(delegator, owner, _token_id)

//     self._burn(_token_id)

// function burn(uint256 _token_id) public {
//     //     @notice Destroy a token
//     //     @dev Only callable by the token owner, their operator, or an approved account.
//     //         Burning a token with a currently active boost, burns the boost.
//     //     @param _token_id The token to burn
//     Utilsdel(utils)._is_approved_or_owner(msg.sender,ownerOf[_token_id],getApproved[_token_id],isApprovedForAll[ownerOf[_token_id]][msg.sender]);
//     uint256 tdata = boost_tokens[_token_id].data;
//     if (tdata != 0) {
//         address delegator = address(uint160(Utilsdel(utils).shift(_token_id, -96)));
//         address owner = ownerOf[_token_id];
//         _burn_boost(_token_id, delegator, owner);
//         emit BurnBoost(delegator, owner, _token_id);
//     }
//     update_enumeration_data(ownerOf[_token_id], Utilsdel(utils).ZERO_ADDRESS, _token_id);
// }





// #@ if mode == "test":
// @external
// def _mint_for_testing(_to: address, _token_id: uint256):
//     self._mint(_to, _token_id)


// @external
// def _burn_for_testing(_token_id: uint256):
//     self._burn(_token_id)


// @view
// @external
// def uint_to_string(_value: uint256) -> String[78]:
//     return self._uint_to_string(_value)

// #@ endif


// @external
// def create_boost(
//     _delegator: address,
//     _receiver: address,
//     _percentage: int256,
//     _cancel_time: uint256,
//     _expire_time: uint256,
//     _id: uint256,
// ):
//     """
//     @notice Create a boost and delegate it to another account.
//     @dev Delegated boost can become negative, and requires active management, else
//         the adjusted veCRV balance of the delegator's account will decrease until reaching 0
//     @param _delegator The account to delegate boost from
//     @param _receiver The account to receive the delegated boost
//     @param _percentage Since veCRV is a constantly decreasing asset, we use percentage to determine
//         the amount of delegator's boost to delegate
//     @param _cancel_time A point in time before _expire_time in which the delegator or their operator
//         can cancel the delegated boost
//     @param _expire_time The point in time, atleast a day in the future, at which the value of the boost
//         will reach 0. After which the negative value is deducted from the delegator's account (and the
//         receiver's received boost only) until it is cancelled. This value is rounded down to the nearest
//         WEEK.
//     @param _id The token id, within the range of [0, 2 ** 96). Useful for contracts given operator status
//         to have specific ranges.
//     """
//     assert msg.sender == _delegator or self.isApprovedForAll[_delegator][msg.sender]  # dev: only delegator or operator

//     expire_time: uint256 = (_expire_time / WEEK) * WEEK

//     expiry_data: uint256 = self.boost[_delegator].expiry_data
//     next_expiry: uint256 = expiry_data % 2 ** 128

//     if next_expiry == 0:
//         next_expiry = Utilsdel(utils).MAX_UINT256

//     assert block.timestamp < next_expiry  # dev: negative boost token is in circulation
//     assert _percentage > 0  # dev: percentage must be greater than 0 bps
//     assert _percentage <= Utilsdel(utils).MAX_PCT  # dev: percentage must be less than 10_000 bps
//     assert _cancel_time <= expire_time  # dev: cancel time is after expiry

//     assert expire_time >= block.timestamp + WEEK  # dev: boost duration must be atleast WEEK
//     assert expire_time <= VotingEscrow(VOTING_ESCROW).locked__end(_delegator)  # dev: boost expiration is past voting escrow lock expiry
//     assert _id < 2 ** 96  # dev: id out of bounds

//     # [delegator address 160][cancel_time uint40][id uint56]
//     token_id: uint256 = Utilsdel(utils).shift(convert(_delegator, uint256), 96) + _id
//     # check if the token exists here before we expend more gas by minting it
//     self._mint(_receiver, token_id)

//     # delegated slope and bias
//     point: Point = self.Utilsdel(utils)._deconstruct_bias_slope(self.boost[_delegator].delegated)

//     time: int256 = convert(block.timestamp, int256)

//     # delegated boost will be positive, if any of circulating boosts are negative
//     # we have already reverted
//     delegated_boost: int256 = point.slope * time + point.bias
//     y: int256 = _percentage * (VotingEscrow(VOTING_ESCROW).balanceOf(_delegator) - delegated_boost) / Utilsdel(utils).MAX_PCT
//     assert y > 0  # dev: no boost

//     point = self.Utilsdel(utils)._calc_bias_slope(time, y, convert(expire_time, int256))
//     assert point.slope < 0  # dev: invalid slope

//     self._mint_boost(token_id, _delegator, _receiver, point.bias, point.slope, _cancel_time, expire_time)

//     # increase the number of expiries for the user
//     if expire_time < next_expiry:
//         next_expiry = expire_time

//     active_delegations: uint256 = Utilsdel(utils).shift(expiry_data, -128)
//     self.account_expiries[_delegator][expire_time] += 1
//     self.boost[_delegator].expiry_data = Utilsdel(utils).shift(active_delegations + 1, 128) + next_expiry

//     log DelegateBoost(_delegator, _receiver, token_id, convert(y, uint256), _cancel_time, _expire_time)

function create_boost(
    address _delegator,
    address _receiver,
    int256 _percentage,
    uint256 _cancel_time,
    uint256 _expire_time,
    uint256 _id
) external {
    //     @notice Create a boost and delegate it to another account.
    //     @dev Delegated boost can become negative, and requires active management, else
    //         the adjusted veCRV balance of the delegator's account will decrease until reaching 0
    //     @param _delegator The account to delegate boost from
    //     @param _receiver The account to receive the delegated boost
    //     @param _percentage Since veCRV is a constantly decreasing asset, we use percentage to determine
    //         the amount of delegator's boost to delegate
    //     @param _cancel_time A point in time before _expire_time in which the delegator or their operator
    //         can cancel the delegated boost
    //     @param _expire_time The point in time, atleast a day in the future, at which the value of the boost
    //         will reach 0. After which the negative value is deducted from the delegator's account (and the
    //         receiver's received boost only) until it is cancelled. This value is rounded down to the nearest
    //         WEEK.
    //     @param _id The token id, within the range of [0, 2 ** 96). Useful for contracts given operator status
    //         to have specific ranges.
    

    uint256 expire_time = Utilsdel(utils).timechecker(_expire_time, _cancel_time, _delegator,VOTING_ESCROW);
    // // uint256 expiry_data = boost[_delegator].expiry_data;
    uint256 next_expiry = boost[_delegator].expiry_data % 2 ** 128;

    if (next_expiry == 0) {
        next_expiry = MAX_UINT256;
    }

    require(block.timestamp < next_expiry, "negative boost token is in circulation");
    require(_percentage > 0 && _percentage <= Utilsdel(utils).uinttoint(MAX_PCT) , "percentage must be greater than 0 bps and less than 10_000 bps");
    require(_id < 2 ** 96, "id out of bounds");

    // [delegator address 160][cancel_time uint40][id uint56]
    
    

    // delegated slope and bias
    Point memory point = Utilsdel(utils)._deconstruct_bias_slope(boost[_delegator].delegated);

    // int256 time = Utilsdel(utils).uinttoint(block.timestamp);

    // delegated boost will be positive, if any of circulating boosts are negative
    // we have already reverted

    int256 y = Utilsdel(utils).ycalc(_delegator, point, _percentage,VOTING_ESCROW);
    require(y > 0, "no boost");

    point = Utilsdel(utils)._calc_bias_slope(Utilsdel(utils).uinttoint(block.timestamp), y, Utilsdel(utils).uinttoint(expire_time));
    require(point.slope < 0, "invalid slope");

    uint256 token_id = Utilsdel(utils).shift((uint160(_delegator)), 96) + _id;


    _mint_boost(token_id, _delegator, _receiver, point, _cancel_time, expire_time);

    // increase the number of expiries for the user
    if (expire_time < next_expiry) {
        next_expiry = expire_time;
    }

    uint256 active_delegations = Utilsdel(utils).shift(boost[_delegator].expiry_data, -128);
    boost[_delegator].expiry_data = Utilsdel(utils).shift(active_delegations + 1, 128) + next_expiry;
    account_expiries[_delegator][expire_time] += 1;
    emit DelegateBoost(_delegator, _receiver, token_id, Utilsdel(utils).inttouint(y), _cancel_time, _expire_time);

}



// @external
// def extend_boost(_token_id: uint256, _percentage: int256, _expire_time: uint256, _cancel_time: uint256):
//     """
//     @notice Extend the boost of an existing boost or expired boost
//     @dev The extension can not decrease the value of the boost. If there are
//         any outstanding negative value boosts which cause the delegable boost
//         of an account to be negative this call will revert
//     @param _token_id The token to extend the boost of
//     @param _percentage The percentage of delegable boost to delegate
//         AFTER burning the token's current boost
//     @param _expire_time The new time at which the boost value will become
//         0, and eventually negative. Must be greater than the previous expiry time,
//         and atleast a WEEK from now, and less than the veCRV lock expiry of the
//         delegator's account. This value is rounded down to the nearest WEEK.
//     """
//     delegator: address = convert(Utilsdel(utils).shift(_token_id, -96), address)
//     receiver: address = self.ownerOf[_token_id]

//     assert msg.sender == delegator or self.isApprovedForAll[delegator][msg.sender]  # dev: only delegator or operator
//     assert receiver != Utilsdel(utils).ZERO_ADDRESS  # dev: boost token does not exist
//     assert _percentage > 0  # dev: percentage must be greater than 0 bps
//     assert _percentage <= Utilsdel(utils).MAX_PCT  # dev: percentage must be less than 10_000 bps

//     # timestamp when delegating account's voting escrow ends - also our second point (lock_expiry, 0)
//     token: Token = self.boost_tokens[_token_id]

//     expire_time: uint256 = (_expire_time / WEEK) * WEEK

//     assert _cancel_time <= expire_time  # dev: cancel time is after expiry
//     assert expire_time >= block.timestamp + WEEK  # dev: boost duration must be atleast one day
//     assert expire_time <= VotingEscrow(VOTING_ESCROW).locked__end(delegator) # dev: boost expiration is past voting escrow lock expiry

//     point: Point = self.Utilsdel(utils)._deconstruct_bias_slope(token.data)

//     time: int256 = convert(block.timestamp, int256)
//     tvalue: int256 = point.slope * time + point.bias

//     # Can extend a token by increasing it's amount but not it's expiry time
//     assert expire_time >= token.expire_time  # dev: new expiration must be greater than old token expiry

//     # if we are extending an unexpired boost, the cancel time must the same or greater
//     # else we can adjust the cancel time to our preference
//     if _cancel_time < (token.dinfo % 2 ** 128):
//         assert block.timestamp >= token.expire_time  # dev: cancel time reduction disallowed

//     # storage variables have been updated: next_expiry + active_delegations
//     self._burn_boost(_token_id, delegator, receiver, point.bias, point.slope)

//     expiry_data: uint256 = self.boost[delegator].expiry_data
//     next_expiry: uint256 = expiry_data % 2 ** 128

//     if next_expiry == 0:
//         next_expiry = Utilsdel(utils).MAX_UINT256

//     assert block.timestamp < next_expiry  # dev: negative outstanding boosts

//     # delegated slope and bias
//     point = self.Utilsdel(utils)._deconstruct_bias_slope(self.boost[delegator].delegated)

//     # verify delegated boost isn't negative, else it'll inflate out vecrv balance
//     delegated_boost: int256 = point.slope * time + point.bias
//     y: int256 = _percentage * (VotingEscrow(VOTING_ESCROW).balanceOf(delegator) - delegated_boost) / Utilsdel(utils).MAX_PCT
//     # a delegator can snipe the exact moment a token expires and create a boost
//     # with 10_000 or some percentage of their boost, which is perfectly fine.
//     # this check is here so the user can't extend a boost unless they actually
//     # have any to give
//     assert y > 0  # dev: no boost
//     assert y >= tvalue  # dev: cannot reduce value of boost

//     point = self.Utilsdel(utils)._calc_bias_slope(time, y, convert(expire_time, int256))
//     assert point.slope < 0  # dev: invalid slope

//     self._mint_boost(_token_id, delegator, receiver, point.bias, point.slope, _cancel_time, expire_time)

//     # increase the number of expiries for the user
//     if expire_time < next_expiry:
//         next_expiry = expire_time

//     active_delegations: uint256 = Utilsdel(utils).shift(expiry_data, -128)
//     self.account_expiries[delegator][expire_time] += 1
//     self.boost[delegator].expiry_data = Utilsdel(utils).shift(active_delegations + 1, 128) + next_expiry

//     log ExtendBoost(delegator, receiver, _token_id, convert(y, uint256), expire_time, _cancel_time)

function extend_boost(uint256 _token_id , int256 _percentage , uint256 _expiry_time ,uint256 _cancel_time,address receiver) external {
    //     @notice Extend the boost of an existing boost or expired boost
    //     @dev The extension can not decrease the value of the boost. If there are
    //         any outstanding negative value boosts which cause the delegable boost
    //         of an account to be negative this call will revert
    //     @param _token_id The token to extend the boost of
    //     @param _percentage The percentage of delegable boost to delegate
    //         AFTER burning the token's current boost
    //     @param _expire_time The new time at which the boost value will become
    //         0, and eventually negative. Must be greater than the previous expiry time,
    //         and atleast a WEEK from now, and less than the veCRV lock expiry of the
    //         delegator's account. This value is rounded down to the nearest WEEK.

    address delegator = address(uint160(Utilsdel(utils).shift(_token_id, -96)));
    
    require(receiver != ZERO_ADDRESS); // dev: boost token does not exist
    require(_percentage > 0); // dev: percentage must be greater than 0 bps
    require(_percentage <= Utilsdel(utils).uinttoint(MAX_PCT)); // dev: percentage must be less than 10_000 bps

    // timestamp when delegating account's voting escrow ends - also our second point (lock_expiry, 0)
    Token memory token = boost_tokens[_token_id];

    uint256 expire_time = Utilsdel(utils).timechecker(_expiry_time, _cancel_time, delegator,VOTING_ESCROW);

    Point memory point = Utilsdel(utils)._deconstruct_bias_slope(token.data);

    int256 time = Utilsdel(utils).uinttoint(block.timestamp);

    // int256 tvalue = point.slope * time + point.bias;

    // Can extend a token by increasing it's amount but not it's expiry time
    require(expire_time >= token.expire_time); // dev: new expiration must be greater than old token expiry

    // if we are extending an unexpired boost, the cancel time must the same or greater
    // else we can adjust the cancel time to our preference
    require(_cancel_time < (token.dinfo % 2 ** 128)); // dev: cancel time reduction disallowed

    // storage variables have been updated: next_expiry + active_delegations


    uint256 expiry_data = boost[delegator].expiry_data;
    uint256 next_expiry = boost[delegator].expiry_data % 2 ** 128;

    if (next_expiry == 0) {
        next_expiry = MAX_UINT256;
    }

    require(block.timestamp < next_expiry); // dev: negative outstanding boosts

    // delegated slope and bias
    point = Utilsdel(utils)._deconstruct_bias_slope(boost[delegator].delegated);

    // verify delegated boost isn't negative, else it'll inflate out vecrv balance
    // int256 delegated_boost = point.slope * time + point.bias;
    int256 y = Utilsdel(utils).ycalc(delegator, point, _percentage,VOTING_ESCROW);

    // a delegator can snipe the exact moment a token expires and create a boost
    // with 10_000 or some percentage of their boost, which is perfectly fine.
    // this check is here so the user can't extend a boost unless they actually
    // have any to give
    require(y > 0); // dev: no boost
    require(y >= (point.slope * time + point.bias)); // dev: cannot reduce value of boost

    point = Utilsdel(utils)._calc_bias_slope(time, y, Utilsdel(utils).uinttoint(expire_time));
    require(point.slope < 0); // dev: invalid slope

    _mint_boost(_token_id, delegator, receiver, point, _cancel_time, expire_time);

    // increase the number of expiries for the user
    if (expire_time < next_expiry) {
        next_expiry = expire_time;
    }

    expiry_data = Utilsdel(utils).shift(expiry_data, -128);
    account_expiries[delegator][expire_time] += 1;
    boost[delegator].expiry_data = Utilsdel(utils).shift((expiry_data) + 1, 128) + next_expiry;
    emit ExtendBoost(delegator, receiver, _token_id, Utilsdel(utils).inttouint(y), expire_time, _cancel_time);
    
    
}


// @external
// def cancel_boost(_token_id: uint256):
//     """
//     @notice Cancel an outstanding boost
//     @dev This does not burn the token, only the boost it represents. The owner
//         of the token or their operator can cancel a boost at any time. The
//         delegator or their operator can only cancel a token after the cancel
//         time. Anyone can cancel the boost if the value of it is negative.
//     @param _token_id The token to cancel
//     """
//     self.cancel_boost(_token_id, msg.sender)


// @external
// def batch_cancel_boosts(_token_ids: uint256[256]):
//     """
//     @notice Cancel many outstanding boosts
//     @dev This does not burn the token, only the boost it represents. The owner
//         of the token or their operator can cancel a boost at any time. The
//         delegator or their operator can only cancel a token after the cancel
//         time. Anyone can cancel the boost if the value of it is negative.
//     @param _token_ids A list of 256 token ids to nullify. The list must
//         be padded with 0 values if less than 256 token ids are provided.
//     """

//     for _token_id in _token_ids:
//         if _token_id == 0:
//             break
//         self.cancel_boost(_token_id, msg.sender)




// @external
// def set_delegation_status(_receiver: address, _delegator: address, _status: bool):
//     """
//     @notice Set or reaffirm the blacklist/whitelist status of a delegator for a receiver.
//     @dev Setting delegator as the Utilsdel(utils).ZERO_ADDRESS enables users to deactive delegations globally
//         and enable the white list. The ability of a delegator to delegate to a receiver
//         is determined by ~(grey_list[_receiver][Utilsdel(utils).ZERO_ADDRESS] ^ grey_list[_receiver][_delegator]).
//     @param _receiver The account which we will be updating it's list
//     @param _delegator The account to disallow/allow delegations from
//     @param _status Boolean of the status to set the _delegator account to
//     """
//     assert msg.sender == _receiver or self.isApprovedForAll[_receiver][msg.sender]
//     self._set_delegation_status(_receiver, _delegator, _status)




// @external
// def batch_set_delegation_status(_receiver: address, _delegators: address[256], _status: uint256[256]):
//     """
//     @notice Set or reaffirm the blacklist/whitelist status of multiple delegators for a receiver.
//     @dev Setting delegator as the Utilsdel(utils).ZERO_ADDRESS enables users to deactive delegations globally
//         and enable the white list. The ability of a delegator to delegate to a receiver
//         is determined by ~(grey_list[_receiver][Utilsdel(utils).ZERO_ADDRESS] ^ grey_list[_receiver][_delegator]).
//     @param _receiver The account which we will be updating it's list
//     @param _delegators List of 256 accounts to disallow/allow delegations from
//     @param _status List of 256 0s and 1s (booleans) of the status to set the _delegator_i account to.
//         if the value is not 0 or 1, execution will break, effectively stopping at the index.

//     """
//     assert msg.sender == _receiver or self.isApprovedForAll[_receiver][msg.sender]  # dev: only receiver or operator

//     for i in range(256):
//         if _status[i] > 1:
//             break
//         self._set_delegation_status(_receiver, _delegators[i], convert(_status[i], bool))



// @view
// @external
// def adjusted_balance_of(_account: address) -> uint256:
//     """
//     @notice Adjusted veCRV balance after accounting for delegations and boosts
//     @dev If boosts/delegations have a negative value, they're effective value is 0
//     @param _account The account to query the adjusted balance of
//     """
//     next_expiry: uint256 = self.boost[_account].expiry_data % 2 ** 128
//     if next_expiry != 0 and next_expiry < block.timestamp:
//         # if the account has a negative boost in circulation
//         # we over penalize by setting their adjusted balance to 0
//         # this is because we don't want to iterate to find the real
//         # value
//         return 0

//     adjusted_balance: int256 = VotingEscrow(VOTING_ESCROW).balanceOf(_account)

//     boost: Boost = self.boost[_account]
//     time: int256 = convert(block.timestamp, int256)

//     if boost.delegated != 0:
//         dpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(boost.delegated)

//         # we take the absolute value, since delegated boost can be negative
//         # if any outstanding negative boosts are in circulation
//         # this can inflate the vecrv balance of a user
//         # taking the absolute value has the effect that it costs
//         # a user to negatively impact another's vecrv balance
//         adjusted_balance -= Utilsdel(utils).abs(dpoint.slope * time + dpoint.bias)

//     if boost.received != 0:
//         rpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(boost.received)

//         # similar to delegated boost, our received boost can be negative
//         # if any outstanding negative boosts are in our possession
//         # However, unlike delegated boost, we do not negatively impact
//         # our adjusted balance due to negative boosts. Instead we take
//         # whichever is greater between 0 and the value of our received
//         # boosts.
//         adjusted_balance += Utilsdel(utils).max(rpoint.slope * time + rpoint.bias, empty(int256))

//     # since we took the absolute value of our delegated boost, it now instead of
//     # becoming negative is positive, and will continue to increase ...
//     # meaning if we keep a negative outstanding delegated balance for long
//     # enought it will not only decrease our vecrv_balance but also our received
//     # boost, however we return the maximum between our adjusted balance and 0
//     # when delegating boost, received boost isn't used for determining how
//     # much we can delegate.
//     return convert(Utilsdel(utils).max(adjusted_balance, empty(int256)), uint256)

function adjusted_balance_of(address _account) external view returns (uint256) {
    return Utilsdel(utils).adjusted_balance_of(_account, boost[_account],VOTING_ESCROW);
}



// @view
// @external
// def delegated_boost(_account: address) -> uint256:
//     """
//     @notice Query the total effective delegated boost value of an account.
//     @dev This value can be greater than the veCRV balance of
//         an account if the account has outstanding negative
//         value boosts.
//     @param _account The account to query
//     """
//     dpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(self.boost[_account].delegated)
//     time: int256 = convert(block.timestamp, int256)
//     return convert(Utilsdel(utils).abs(dpoint.slope * time + dpoint.bias), uint256)




// @view
// @external
// def received_boost(_account: address) -> uint256:
//     """
//     @notice Query the total effective received boost value of an account
//     @dev This value can be 0, even with delegations which have a large value,
//         if the account has any outstanding negative value boosts.
//     @param _account The account to query
//     """
//     rpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(self.boost[_account].received)
//     time: int256 = convert(block.timestamp, int256)
//     return convert(Utilsdel(utils).max(rpoint.slope * time + rpoint.bias, empty(int256)), uint256)

function received_boost(address _account) public view returns (uint256) {
    return Utilsdel(utils).received_boost(boost[_account].received);
}



// @view
// @external
// def token_boost(_token_id: uint256) -> int256:
//     """
//     @notice Query the effective value of a boost
//     @dev The effective value of a boost is negative after it's expiration
//         date.
//     @param _token_id The token id to query
//     """
//     tpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(self.boost_tokens[_token_id].data)
//     time: int256 = convert(block.timestamp, int256)
//     return tpoint.slope * time + tpoint.bias

function token_boost(uint256 _token_id) public view returns (int256) {
    //     @notice Query the effective value of a boost
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    Point memory tpoint = Utilsdel(utils)._deconstruct_bias_slope(boost_tokens[_token_id].data);
    int256 time = Utilsdel(utils).uinttoint(block.timestamp);
    return tpoint.slope * time + tpoint.bias;
}


// @view
// @external
// def token_expiry(_token_id: uint256) -> uint256:
//     """
//     @notice Query the timestamp of a boost token's expiry
//     @dev The effective value of a boost is negative after it's expiration
//         date.
//     @param _token_id The token id to query
//     """
//     return self.boost_tokens[_token_id].expire_time

function token_expiry(uint256 _token_id) public view returns (uint256) {
    //     @notice Query the timestamp of a boost token's expiry
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    return boost_tokens[_token_id].expire_time;
}


// @view
// @external
// def token_cancel_time(_token_id: uint256) -> uint256:
//     """
//     @notice Query the timestamp of a boost token's cancel time. This is
//         the point at which the delegator can nullify the boost. A receiver
//         can cancel a token at any point. Anyone can nullify a token's boost
//         after it's expiration.
//     @param _token_id The token id to query
//     """
//     return self.boost_tokens[_token_id].dinfo % 2 ** 128

function token_cancel_time(uint256 _token_id) public view returns (uint256) {
    //     @notice Query the timestamp of a boost token's cancel time. This is
    //         the point at which the delegator can nullify the boost. A receiver
    //         can cancel a token at any point. Anyone can nullify a token's boost
    //         after it's expiration.
    //     @param _token_id The token id to query
    return boost_tokens[_token_id].dinfo % 2 ** 128;
}


// @view
// @external
// def calc_boost_bias_slope(
//     _delegator: address,
//     _percentage: int256,
//     _expire_time: int256,
//     _extend_token_id: uint256 = 0
// ) -> (int256, int256):
//     """
//     @notice Calculate the bias and slope for a boost.
//     @param _delegator The account to delegate boost from
//     @param _percentage The percentage of the _delegator's delegable
//         veCRV to delegate.
//     @param _expire_time The time at which the boost value of the token
//         will reach 0, and subsequently become negative
//     @param _extend_token_id OPTIONAL token id, which if set will first nullify
//         the boost of the token, before calculating the bias and slope. Useful
//         for calculating the new bias and slope when extending a token, or
//         determining the bias and slope of a subsequent token after cancelling
//         an existing one. Will have no effect if _delegator is not the delegator
//         of the token.
//     """
//     time: int256 = convert(block.timestamp, int256)
//     assert _percentage > 0  # dev: percentage must be greater than 0
//     assert _percentage <= Utilsdel(utils).MAX_PCT  # dev: percentage must be less than or equal to 100%
//     assert _expire_time > time + WEEK  # dev: Invalid min expiry time

//     lock_expiry: int256 = convert(VotingEscrow(VOTING_ESCROW).locked__end(_delegator), int256)
//     assert _expire_time <= lock_expiry

//     ddata: uint256 = self.boost[_delegator].delegated

//     if _extend_token_id != 0 and convert(Utilsdel(utils).shift(_extend_token_id, -96), address) == _delegator:
//         # decrease the delegated bias and slope by the token's bias and slope
//         # only if it is the delegator's and it is within the bounds of existence
//         ddata -= self.boost_tokens[_extend_token_id].data

//     dpoint: Point = self.Utilsdel(utils)._deconstruct_bias_slope(ddata)

//     delegated_boost: int256 = dpoint.slope * time + dpoint.bias
//     assert delegated_boost >= 0  # dev: outstanding negative boosts

//     y: int256 = _percentage * (VotingEscrow(VOTING_ESCROW).balanceOf(_delegator) - delegated_boost) / Utilsdel(utils).MAX_PCT
//     assert y > 0  # dev: no boost

//     slope: int256 = -y / (_expire_time - time)
//     assert slope < 0  # dev: invalid slope

//     bias: int256 = y - slope * time

//     return bias, slope

function calc_boost_bias_slope(
    address _delegator,
    int256 _percentage,
    int256 _expire_time,
    uint256 _extend_token_id
) public view returns (Point memory) {
    return Utilsdel(utils).calc_boost_bias_slope(_delegator, _percentage, _expire_time, _extend_token_id, boost[_delegator].delegated, boost_tokens[_extend_token_id].data,VOTING_ESCROW);

}


// @pure
// @external
// def get_token_id(_delegator: address, _id: uint256) -> uint256:
//     """
//     @notice Simple method to get the token id's mintable by a delegator
//     @param _delegator The address of the delegator
//     @param _id The id value, must be less than 2 ** 96
//     """
//     assert _id < 2 ** 96  # dev: invalid _id
//     return Utilsdel(utils).shift(convert(_delegator, uint256), 96) + _id


}