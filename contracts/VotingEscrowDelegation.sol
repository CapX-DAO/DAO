// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


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


import {SafeCast} from "../dependencies/open-zeppelin/SafeCast.sol";


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


event ApprovalForAll(
    address _owner,
    address _operator,
    bool _approved
);



event Transfer(
    address _from,
    address _to,
    uint256 _token_id
);


event BurnBoost(
    address _delegator,
    address _receiver,
    uint256 _token_id
);


event DelegateBoost(
    address _delegator,
    address _receiver,
    uint256 _token_id,
    uint256 _amount,
    uint256 _cancel_time,
    uint256 _expire_time
);



event ExtendBoost(
    address _delegator,
    address _receiver,
    uint256 _token_id,
    uint256 _amount,
    uint256 _expire_time,
    uint256 _cancel_time
);



event TransferBoost(
    address _from,
    address _to,
    uint256 _token_id,
    uint256 _amount,
    uint256 _expire_time
);


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



struct Token {
    // [bias uint128][slope int128]
    uint256 data;
    // [delegator pos 128][cancel time 128]
    uint256 dinfo;
    // [global 128][local 128]
    uint256 position;
    uint256 expire_time;
}



struct Point {
    int256 bias;
    int256 slope;
}




address public VOTING_ESCROW;
address public utils;




string public name;
string public symbol;
string public base_uri;



uint256 public totalSupply;
// use totalSupply to determine the length
mapping(uint256 => uint256) public tokenByIndex;
// use balanceOf to determine the length
mapping(address => mapping(uint256 => uint256)) public tokenOfOwnerByIndex;

mapping(address => Boost) public boost;
mapping(uint256 => Token) public boost_tokens;



mapping(address => mapping(uint256 => uint256)) public token_of_delegator_by_index;
mapping(address => uint256) public total_minted;
// address => timestamp => # of delegations expiring
mapping(address => mapping(uint256 => uint256)) public account_expiries;



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


function commit_transfer_ownership(address _addr) public {
    //     @notice Transfer ownership of contract to `addr`
    //     @param _addr Address to have ownership transferred to
    require(msg.sender == admin, "admin only");
    future_admin = _addr;
}



function accept_transfer_ownership() public {
    //     @notice Accept admin role, only callable by future admin
    //     @dev Only callable by future admin
    require(msg.sender == future_admin, "future admin only");
    admin = future_admin;
}






function set_base_uri(string memory _base_uri) public {
    //     @notice Set the base URI for the contract
    //     @param _base_uri The base URI for the contract
    
    require(msg.sender == admin, "admin only");
    base_uri = _base_uri;
}



constructor(string memory _name, string memory _symbol, string memory _base_uri,address _VOTING_ESCROW,address _utils) {
    name = _name;
    symbol = _symbol;
    base_uri = _base_uri;
    VOTING_ESCROW = _VOTING_ESCROW;
    utils = _utils;


    admin = msg.sender;

}



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
                require(false ,"Failed to find next expiry");
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



function _transfer_boost(address _from,address _to,int256 _bias,int256 _slope) external {
    uint256 data = Utilsdel(utils).shift(Utilsdel(utils).inttouint(_bias), 128) + Utilsdel(utils).inttouint(Utilsdel(utils).abs(_slope));
    boost[_from].received -= data;
    boost[_to].received += data;
}



function _set_delegation_status(address _receiver,address _delegator,bool _status) external {
    grey_list[_receiver][_delegator] = _status;
    emit GreyListUpdated(_receiver, _delegator, _status);
}



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



function adjusted_balance_of(address _account) external view returns (uint256) {
    return Utilsdel(utils).adjusted_balance_of(_account, boost[_account],VOTING_ESCROW);
}



function received_boost(address _account) public view returns (uint256) {
    return Utilsdel(utils).received_boost(boost[_account].received);
}



function token_boost(uint256 _token_id) public view returns (int256) {
    //     @notice Query the effective value of a boost
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    Point memory tpoint = Utilsdel(utils)._deconstruct_bias_slope(boost_tokens[_token_id].data);
    int256 time = Utilsdel(utils).uinttoint(block.timestamp);
    return tpoint.slope * time + tpoint.bias;
}



function token_expiry(uint256 _token_id) public view returns (uint256) {
    //     @notice Query the timestamp of a boost token's expiry
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    return boost_tokens[_token_id].expire_time;
}



function token_cancel_time(uint256 _token_id) public view returns (uint256) {
    //     @notice Query the timestamp of a boost token's cancel time. This is
    //         the point at which the delegator can nullify the boost. A receiver
    //         can cancel a token at any point. Anyone can nullify a token's boost
    //         after it's expiration.
    //     @param _token_id The token id to query
    return boost_tokens[_token_id].dinfo % 2 ** 128;
}



function calc_boost_bias_slope(
    address _delegator,
    int256 _percentage,
    int256 _expire_time,
    uint256 _extend_token_id
) public view returns (Point memory) {
    return Utilsdel(utils).calc_boost_bias_slope(_delegator, _percentage, _expire_time, _extend_token_id, boost[_delegator].delegated, boost_tokens[_extend_token_id].data,VOTING_ESCROW);

}




}