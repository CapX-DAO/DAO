// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Utils} from "./Utils.sol";
import "./VEDinterfaces.sol";


contract VotingEscrowDelegation is VED {


constructor(string memory _name, string memory _symbol, string memory _base_uri) {
    name = _name;
    symbol = _symbol;
    base_uri = _base_uri;

    admin = msg.sender;

}



function _update_enumeration_data(address _from,address _to,uint256 _token_id,uint256 balance_of_from,uint256 balance_of_to) external {
        address delegator = address(uint160((Utils.shift(_token_id, (-96)))));
        uint256 position_data = boost_tokens[_token_id].position;
        uint256 local_pos = position_data % 2 ** 128;
        uint256 global_pos = Utils.shift(position_data, -128);
        uint256 delegator_pos = Utils.shift(boost_tokens[_token_id].dinfo, -128);


        if (_from == Utils.ZERO_ADDRESS) {
            global_pos = totalSupply;
            position_data = Utils.shift(global_pos, 128) + local_pos;
            // this is a new token so we get the index of a new spot
            delegator_pos = total_minted[delegator];

            tokenByIndex[global_pos] = _token_id;
            tokenOfOwnerByIndex[_to][local_pos] = _token_id;
            boost_tokens[_token_id].position = position_data;

            // we only mint tokens in the create_boost fn, and this is called
            // before we update the cancel_time so we can just set the value
            // of dinfo to the shifted position
            boost_tokens[_token_id].dinfo = Utils.shift(delegator_pos, 128) + (delegator_pos % 2 ** 128);
            token_of_delegator_by_index[delegator][delegator_pos] = _token_id;
            total_minted[delegator] = delegator_pos + 1;

            
            totalSupply += 1;
        } else if (_to == Utils.ZERO_ADDRESS) {
            

            // burning - This is called after updates to balance and totalSupply
            // we operate on both the global array and local array
            uint256 last_global_index = totalSupply;
            uint256 last_delegator_pos = total_minted[delegator] - 1;

            if (global_pos != last_global_index) {
                // swap - set the token we're burnings position to the token in the last index
                uint256 last_global_token = tokenByIndex[last_global_index];
                uint256 last_global_token_pos = boost_tokens[last_global_token].position;
                // update the global position of the last global token
                boost_tokens[last_global_token].position = Utils.shift(global_pos, 128) + (last_global_token_pos % 2 ** 128);
                tokenByIndex[global_pos] = last_global_token;
                
            }
            tokenByIndex[last_global_index] = 0;

            if (local_pos != balance_of_from) {
                // swap - set the token we're burnings position to the token in the last index
                uint256 last_local_token = tokenOfOwnerByIndex[_from][balance_of_from];
                // uint256 last_local_token_pos = ;
                // update the local position of the last local token
                boost_tokens[last_local_token].position = Utils.shift(boost_tokens[last_local_token].position / 2 ** 128, 128) + local_pos;
                tokenOfOwnerByIndex[_from][local_pos] = last_local_token;
            }
            tokenOfOwnerByIndex[_from][balance_of_from] = 0;
            boost_tokens[_token_id].position = 0;

            if (delegator_pos != last_delegator_pos) {
                uint256 last_delegator_token = token_of_delegator_by_index[delegator][last_delegator_pos];
                uint256 last_delegator_token_dinfo = boost_tokens[last_delegator_token].dinfo;
                // update the last tokens position data and maintain the correct cancel time
                boost_tokens[last_delegator_token].dinfo = Utils.shift(delegator_pos, 128) + (last_delegator_token_dinfo % 2 ** 128);
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
                boost_tokens[last_local_token].position = Utils.shift(last_local_token_pos / 2 ** 128, 128) + local_pos;
                tokenOfOwnerByIndex[_from][local_pos] = last_local_token;
            }
            tokenOfOwnerByIndex[_from][balance_of_from] = 0;

            // to is simple we just add to the end of the list
            local_pos = balance_of_to;
            tokenOfOwnerByIndex[_to][local_pos] = _token_id;
            boost_tokens[_token_id].position = Utils.shift(global_pos, 128) + local_pos;
        }
        

        
}


function _mint_boost(uint256 _token_id,address _delegator,address _receiver,Point memory point,uint256 _cancel_time,uint256 _expire_time) private {
    // uint256 is_whitelist = (grey_list[_receiver][Utils.ZERO_ADDRESS] ? 1 : 0);
    // uint256 delegator_status = (grey_list[_receiver][_delegator] ? 1 : 0);
    require ((((grey_list[_receiver][Utils.ZERO_ADDRESS] ? 1 : 0) ^ (grey_list[_receiver][_delegator] ? 1 : 0))== 0)); // dev: mint boost not allowed

    uint256 data = Utils.shift(Utils.inttouint(point.bias), 128) + Utils.inttouint(Utils.abs(point.slope));
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
    token.dinfo = Utils.shift(token.dinfo / 2 ** 128, 128);
    token.expire_time = 0;
    boost_tokens[_token_id] = token;

    // update the next expiry data
    uint256 expiry_data = boost[_delegator].expiry_data;
    uint256 next_expiry = expiry_data % 2 ** 128;
    uint256 active_delegations = Utils.shift(expiry_data, -128) - 1;

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
                require(false, "Failed to find next expiry");
            }
            uint256 week_ts = expire_time + Utils.WEEK * (i + 1);
            if (account_expiries[_delegator][week_ts] > 0) {
                next_expiry = week_ts;
                break;
            }
        }
    } else if (active_delegations == 0) {
        next_expiry = 0;
    }

    boost[_delegator].expiry_data = Utils.shift(active_delegations, 128) + next_expiry;
    account_expiries[_delegator][expire_time] = expiries - 1;
}


function _transfer_boost(address _from,address _to,int256 _bias,int256 _slope) external {
    uint256 data = Utils.shift(Utils.inttouint(_bias), 128) + Utils.inttouint(Utils.abs(_slope));
    boost[_from].received -= data;
    boost[_to].received += data;
}


function _set_delegation_status(address _receiver,address _delegator,bool _status) external {
    grey_list[_receiver][_delegator] = _status;
    emit Utils.GreyListUpdated(_receiver, _delegator, _status);
}



function create_boost(
    address _delegator,
    address _receiver,
    int256 _percentage,
    uint256 _cancel_time,
    uint256 _expire_time,
    uint256 _id,
    uint256 token_id
) external  {
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
    

    uint256 expire_time = Utils.timechecker(_expire_time, _cancel_time, _delegator);
    // uint256 expiry_data = boost[_delegator].expiry_data;
    uint256 next_expiry = boost[_delegator].expiry_data % 2 ** 128;

    if (next_expiry == 0) {
        next_expiry = Utils.MAX_UINT256;
    }

    require(block.timestamp < next_expiry, "negative boost token is in circulation");
    require(_percentage > 0 && _percentage <= Utils.uinttoint(Utils.MAX_PCT) , "percentage must be greater than 0 bps and less than 10_000 bps");
    require(_id < 2 ** 96, "id out of bounds");

    // [delegator address 160][cancel_time uint40][id uint56]
    

    // delegated slope and bias
    Point memory point = Utils._deconstruct_bias_slope(boost[_delegator].delegated);

    // int256 time = Utils.uinttoint(block.timestamp);

    // delegated boost will be positive, if any of circulating boosts are negative
    // we have already reverted

    int256 y = Utils.ycalc(_delegator, point, _percentage);
    require(y > 0, "no boost");

    point = Utils._calc_bias_slope(Utils.uinttoint(block.timestamp), y, Utils.uinttoint(expire_time));
    require(point.slope < 0, "invalid slope");


    _mint_boost(token_id, _delegator, _receiver, point, _cancel_time, expire_time);

    // increase the number of expiries for the user
    if (expire_time < next_expiry) {
        next_expiry = expire_time;
    }

    uint256 active_delegations = Utils.shift(boost[_delegator].expiry_data, -128);
    boost[_delegator].expiry_data = Utils.shift(active_delegations + 1, 128) + next_expiry;
    account_expiries[_delegator][expire_time] += 1;
    emit Utils.DelegateBoost(_delegator, _receiver, token_id, Utils.inttouint(y), _cancel_time, _expire_time);

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

    address delegator = address(uint160(Utils.shift(_token_id, -96)));
    
    require(receiver != Utils.ZERO_ADDRESS); // dev: boost token does not exist
    require(_percentage > 0); // dev: percentage must be greater than 0 bps
    require(_percentage <= Utils.uinttoint(Utils.MAX_PCT)); // dev: percentage must be less than 10_000 bps

    // timestamp when delegating account's voting escrow ends - also our second point (lock_expiry, 0)
    Token memory token = boost_tokens[_token_id];

    uint256 expire_time = Utils.timechecker(_expiry_time, _cancel_time, delegator);

    Point memory point = Utils._deconstruct_bias_slope(token.data);

    int256 time = Utils.uinttoint(block.timestamp);

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
        next_expiry = Utils.MAX_UINT256;
    }

    require(block.timestamp < next_expiry); // dev: negative outstanding boosts

    // delegated slope and bias
    point = Utils._deconstruct_bias_slope(boost[delegator].delegated);

    // verify delegated boost isn't negative, else it'll inflate out vecrv balance
    // int256 delegated_boost = point.slope * time + point.bias;
    int256 y = Utils.ycalc(delegator, point, _percentage);

    // a delegator can snipe the exact moment a token expires and create a boost
    // with 10_000 or some percentage of their boost, which is perfectly fine.
    // this check is here so the user can't extend a boost unless they actually
    // have any to give
    require(y > 0); // dev: no boost
    require(y >= (point.slope * time + point.bias)); // dev: cannot reduce value of boost

    point = Utils._calc_bias_slope(time, y, Utils.uinttoint(expire_time));
    require(point.slope < 0); // dev: invalid slope

    _mint_boost(_token_id, delegator, receiver, point, _cancel_time, expire_time);

    // increase the number of expiries for the user
    if (expire_time < next_expiry) {
        next_expiry = expire_time;
    }

    expiry_data = Utils.shift(expiry_data, -128);
    account_expiries[delegator][expire_time] += 1;
    boost[delegator].expiry_data = Utils.shift((expiry_data) + 1, 128) + next_expiry;
    emit Utils.ExtendBoost(delegator, receiver, _token_id, Utils.inttouint(y), expire_time, _cancel_time);
    
    
}


function adjusted_balance_of(address _account) public view returns (uint256) {
    return Utils.adjusted_balance_of(_account, boost);
}


function received_boost(address _account) public view returns (uint256) {
    return Utils.received_boost(boost[_account].received);
}


function token_boost(uint256 _token_id) public view returns (int256) {
    //     @notice Query the effective value of a boost
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    Point memory tpoint = Utils._deconstruct_bias_slope(boost_tokens[_token_id].data);
    int256 time = Utils.uinttoint(block.timestamp);
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
    return Utils.calc_boost_bias_slope(_delegator, _percentage, _expire_time, _extend_token_id, boost[_delegator].delegated, boost_tokens[_extend_token_id].data);

}}