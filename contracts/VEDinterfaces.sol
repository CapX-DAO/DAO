// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Utils} from "./Utils.sol";

// interface VotingEscrow:
//     def balanceOf(_account: address) -> int256: view
//     def locked__end(_addr: address) -> uint256: view
interface VE {
    function balanceOf(address _account) external view returns (uint256);
    function locked__end(address _addr) external view returns (uint256);
}

abstract contract VED {
  

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
mapping(address => uint256[]) public tokenOfOwnerByIndex;

mapping(address => Boost) public boost;
mapping(uint256 => Token) public boost_tokens;

// boost: HashMap[address, Boost]
// boost_tokens: HashMap[uint256, Token]



// token_of_delegator_by_index: public(HashMap[address, uint256[MAX_UINT256]])
// total_minted: public(HashMap[address, uint256])
// # address => timestamp => # of delegations expiring
// account_expiries: public(HashMap[address, HashMap[uint256, uint256]])

mapping(address => uint256[]) public token_of_delegator_by_index;
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
    uint256 is_whitelist = (grey_list[_to][Utils.ZERO_ADDRESS] ? 1 : 0);
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


    
}