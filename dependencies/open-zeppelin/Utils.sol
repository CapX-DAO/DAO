// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import {VotingEscrowDelegation} from "../../contracts/VotingEscrowDelegation.sol";
import {SignedSafeMath} from "./SignedSafeMath.sol";
import {SafeMath} from "./SafeMath.sol";

interface VE_util {
    function balanceOf(address _account) external view returns (uint256);
    function locked__end(address _addr) external view returns (uint256);
}


contract Utils {
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

constructor() {

}




    function uinttoint(uint num) public pure returns (int) {
    return int(num);
  }

  function inttouint(int num) public pure returns (uint) {
    return uint(num);
  }

  function timechecker(uint256 _expiry_time,uint256 _cancel_time,address delegator,address VOTING_ESCROW) public view returns (uint256) {
      uint256 expire_time = (_expiry_time / WEEK) * WEEK;

    require(_cancel_time <= expire_time,"0"); // dev: cancel time is after expiry
    require(expire_time >= block.timestamp + WEEK,"1"); // dev: boost duration must be atleast one day
    require(expire_time <= VE_util(VOTING_ESCROW).locked__end(delegator),"2"); // dev: boost expiration is past voting escrow lock expiry

    return expire_time;
    
  }


  

  struct slice {
        uint _len;
        uint _ptr;
    }



     function memcpy(uint dest, uint src, uint len) public pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

   function toSlice(string memory a) public pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(a, 0x20)
        }
        return slice(bytes(a).length, ptr);
    }


  function concat(string memory a, string memory b) public pure returns (string memory) {
       slice memory self = toSlice(a);
       slice memory other = toSlice(b);
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    function shift(uint256 _x, int256 _n) public pure returns (uint256) {
    //     @notice Shift a number left by n bits
    //     @param _x The number to shift
    //     @param _n The number of bits to shift
    if (_n >= 0) {
        return ((_x) * (uint256(2) ** inttouint(_n)));
    } else {
        return ((_x) / (uint256(2) ** inttouint(-_n)));
    }
}

function shift(int256 _x, int256 _n) public pure returns (int256) {
    //     @notice Shift a number left by n bits
    //     @param _x The number to shift
    //     @param _n The number of bits to shift
    if (_n >= 0) {
        return ((_x) * uinttoint(uint256(2) ** inttouint(_n)));
    } else {
        return ((_x) / uinttoint(uint256(2) ** inttouint(-_n)));
    }
}

function _uint_to_string(uint256 _x) public pure returns (string memory) {
     if (_x == 0) {
            return "0";
        }
        uint j = _x;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_x != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_x - _x / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _x /= 10;
        }
        return string(bstr);
}

function _deconstruct_bias_slope(uint256 _data) public pure returns (VotingEscrowDelegation.Point memory) {
    return VotingEscrowDelegation.Point(uinttoint(shift(_data, -128)), -uinttoint(_data % (2 ** 128)));
}

function _calc_bias_slope(int256 _x,int256 _y,int256 _expire_time) public pure returns (VotingEscrowDelegation.Point memory) {
    // SLOPE: (y2 - y1) / (x2 - x1)
    // BIAS: y = mx + b -> y - mx = b
    int256 slope = -_y / (_expire_time - _x);
    return VotingEscrowDelegation.Point(_y - slope * _x, slope);
}

function max(uint256 a, uint256 b) public pure returns (uint256) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

function max(int256 a, int256 b) public pure returns (int256) {
    if (a > b) {
        return a;
    } else {
        return b;
    }
}

function abs(int256 a) public pure returns (int256) {
    if (a < 0) {
        return -a;
    } else {
        return a;
    }
}

function get_token_id(address _delegator , uint256 _id) public pure returns (uint256) {
    //     @notice Simple method to get the token id's mintable by a delegator
    //     @param _delegator The address of the delegator
    //     @param _id The id value, must be less than 2 ** 96
    require(_id < 2 ** 96, "invalid _id");
    
    return shift(uint256(uint160(_delegator)), 96) + _id;
}

function is_contract(address _addr) public view returns (bool isContract){
  uint32 size;
  assembly {
    size := extcodesize(_addr)
  }
  return (size > 0);
}

function received_boost(uint256 boost_recieved) public view returns (uint256) {
    //     @notice Query the total effective received boost value of an account
    //     @dev This value can be 0, even with delegations which have a large value,
    //         if the account has any outstanding negative value boosts.
    //     @param _account The account to query
    VotingEscrowDelegation.Point memory rpoint = _deconstruct_bias_slope(boost_recieved);
    int256 time = uinttoint(block.timestamp);
    return inttouint(max(rpoint.slope * time + rpoint.bias, 0));
}

function _is_approved_or_owner(address _spender,address owner_of_token_id, address get_approved_token_id , bool isapprovedforall_owner_spender) public pure {
    require(_spender == owner_of_token_id
        || _spender == get_approved_token_id
        || isapprovedforall_owner_spender,"must be owner or approved");
}

function adjusted_balance_of(address _account,VotingEscrowDelegation.Boost memory boost_account,address VOTING_ESCROW) public view returns (uint256) {
        // @notice Adjusted veCRV balance after accounting for delegations and boosts
        // @dev If boosts/delegations have a negative value, they're effective value is 0
        // @param _account The account to query the adjusted balance of
    uint256 next_expiry = boost_account.expiry_data % 2 ** 128;
    if (next_expiry != 0 && next_expiry < block.timestamp) {
        // if the account has a negative boost in circulation
        // we over penalize by setting their adjusted balance to 0
        // this is because we don't want to iterate to find the real
        // value
        return 0;
    }

    int256 adjusted_balance = uinttoint( VE_util(VOTING_ESCROW).balanceOf(_account));
    int256 time = uinttoint(block.timestamp);

    if (boost_account.delegated != 0) {
        VotingEscrowDelegation.Point memory dpoint = _deconstruct_bias_slope(boost_account.delegated);

        // we take the absolute value, since delegated boost can be negative
        // if any outstanding negative boosts are in circulation
        // this can inflate the vecrv balance of a user
        // taking the absolute value has the effect that it costs
        // a user to negatively impact another's vecrv balance
        adjusted_balance -= abs(dpoint.slope * time + dpoint.bias);
    }

    if (boost_account.received != 0) {
        VotingEscrowDelegation.Point memory rpoint = _deconstruct_bias_slope(boost_account.received);

        // similar to delegated boost, our received boost can be negative
        // if any outstanding negative boosts are in our possession
        // However, unlike delegated boost, we do not negatively impact
        // our adjusted balance due to negative boosts. Instead we take
        // whichever is greater between 0 and the value of our received
        // boosts.
        adjusted_balance += (max(rpoint.slope * time + rpoint.bias, 0));
    }

    

    // since we took the absolute value of our delegated boost, it now instead of
    // becoming negative is positive, and will continue to increase ...
    // meaning if we keep a negative outstanding delegated balance for long
    // enought it will not only decrease our vecrv_balance but also our received
    // boost, however we return the maximum between our adjusted balance and 0
    // when delegating boost, received boost isn't used for determining how
    // much we can delegate.
    return inttouint(max(adjusted_balance, 0));
    

}

function ycalc(address _delegator,VotingEscrowDelegation.Point memory point, int256 _percentage,address VOTING_ESCROW) public view returns (int256) {
    int256 delegated_boost_var = SignedSafeMath.add(SignedSafeMath.mul(point.slope, uinttoint(block.timestamp)) ,point.bias);
    uint256 delegator_balance_ve = (VE_util(VOTING_ESCROW).balanceOf(_delegator));
    int256 y = SignedSafeMath.mul(_percentage, SignedSafeMath.div(SignedSafeMath.sub(uinttoint(delegator_balance_ve),delegated_boost_var),uinttoint(MAX_PCT)));
    return y;
}

function delegated_boost(address _account,VotingEscrowDelegation.Boost memory boost_account) public view returns (uint256) {
    //     @notice Query the total effective delegated boost value of an account.
    //     @dev This value can be greater than the veCRV balance of
    //         an account if the account has outstanding negative
    //         value boosts.
    //     @param _account The account to query
    VotingEscrowDelegation.Point memory dpoint = _deconstruct_bias_slope(boost_account.delegated);
    int256 time = uinttoint(block.timestamp);
    return inttouint(abs(dpoint.slope * time + dpoint.bias));
}

function calc_boost_bias_slope(
    address _delegator,
    int256 _percentage,
    int256 _expire_time,
    uint256 _extend_token_id,
    uint256 boost_delegator_delegated,
    uint256 boost_tokens_extend_token_id_data,address VOTING_ESCROW
) public view returns (VotingEscrowDelegation.Point memory) {
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
    // int256 time = uinttoint(block.timestamp);
    require(_percentage > 0, "percentage must be greater than 0");
    require(_percentage <= uinttoint(MAX_PCT), "percentage must be less than or equal to 100%");
    require(_expire_time > uinttoint(block.timestamp + (WEEK)), "Invalid min expiry time");

    int256 lock_expiry = uinttoint(VE_util(VOTING_ESCROW).locked__end(_delegator));
    require(_expire_time <= lock_expiry, "Invalid expiry time");

    

    if (_extend_token_id != 0 && address(uint160(shift(_extend_token_id, -96))) == _delegator) {
        // decrease the delegated bias and slope by the token's bias and slope
        // only if it is the delegator's and it is within the bounds of existence
        boost_delegator_delegated -= boost_tokens_extend_token_id_data;
    }

    VotingEscrowDelegation.Point memory dpoint = _deconstruct_bias_slope(boost_delegator_delegated);

    int256 delegated_boost_var = dpoint.slope * uinttoint(block.timestamp) + dpoint.bias;
    require(delegated_boost_var >= 0, "outstanding negative boosts");

    int256 y = ycalc(_delegator,dpoint,_percentage,VOTING_ESCROW);
    require(y > 0, "no boost");

    int256 slope = -y / (_expire_time - uinttoint(block.timestamp));
    require(slope < 0, "invalid slope");

    return VotingEscrowDelegation.Point(y - slope * uinttoint(block.timestamp), slope);

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
//     tpoint: Point = self._deconstruct_bias_slope(self.boost_tokens[_token_id].data)
//     time: int256 = convert(block.timestamp, int256)
//     return tpoint.slope * time + tpoint.bias

function token_boost(uint256 _token_id,address VOTING_ESCROW_DELEGATION) public view returns (int256) {
    //     @notice Query the effective value of a boost
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    
VotingEscrowDelegation.Point memory tpoint = _deconstruct_bias_slope(VotingEscrowDelegation(VOTING_ESCROW_DELEGATION).get_boost_token_data(_token_id));
    int256 time = uinttoint(block.timestamp);
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

function token_expiry(uint256 _token_id,address VOTING_ESCROW_DELEGATION) public view returns (uint256) {
    //     @notice Query the timestamp of a boost token's expiry
    //     @dev The effective value of a boost is negative after it's expiration
    //         date.
    //     @param _token_id The token id to query
    return VotingEscrowDelegation(VOTING_ESCROW_DELEGATION).get_boost_token_data(_token_id);
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

function token_cancel_time(uint256 _token_id,address VOTING_ESCROW_DELEGATION) public view returns (uint256) {
    //     @notice Query the timestamp of a boost token's cancel time. This is
    //         the point at which the delegator can nullify the boost. A receiver
    //         can cancel a token at any point. Anyone can nullify a token's boost
    //         after it's expiration.
    //     @param _token_id The token id to query
    return VotingEscrowDelegation(VOTING_ESCROW_DELEGATION).get_boost_token_dinfo(_token_id) % 2 ** 128;
}






}