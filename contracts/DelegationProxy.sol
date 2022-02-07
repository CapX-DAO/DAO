
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
//import ERC20 token


interface VeDelegation {
    function adjusted_balance_of(address _account) external view returns (uint256);
}

interface ERC20 {
    function balanceOf(address _owner) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

contract Delegation{
  event CommitAdmins(address ownership_admin, address emergency_admin);
  
  event ApplyAdmins(address ownership_admin, address emergency_admin);

  
  event DelegationSet(address delegation);


  address constant VOTING_ESCROW = 0x5f3b5DfEb7B28CDbD7FAba78963EE202a494e2A2;
  address constant ZERO_ADDRESS = address(0);


  address public delegation;


  address public emergency_admin; 
  address public ownership_admin; 
  address public future_emergency_admin; 
  address public future_ownership_admin;



  function __init__(address _delegation, address _o_admin,address _e_admin) public {
    delegation = _delegation;

    ownership_admin = _o_admin;
    emergency_admin = _e_admin;

    emit DelegationSet(_delegation);
  }



  function adjusted_balance_of(address _account) public view returns (uint256) {
    address _delegation = delegation;

    if (_delegation == ZERO_ADDRESS) {
      return ERC20(VOTING_ESCROW).balanceOf(_account);
    }

    return VeDelegation(_delegation).adjusted_balance_of(_account);
  }



  function kill_delegation() public {

    require(msg.sender == ownership_admin || msg.sender == emergency_admin);

    delegation = ZERO_ADDRESS;
    emit DelegationSet(ZERO_ADDRESS);
  }


  function set_delegation(address _delegation) public {
    require(msg.sender == ownership_admin);

    // call `adjusted_balance_of` to make sure it works
    VeDelegation(_delegation).adjusted_balance_of(msg.sender);

    delegation = _delegation;
    emit DelegationSet(_delegation);
  }



  function commit_set_admins(address  _o_admin,address  _e_admin) public {
    require(msg.sender == _o_admin);

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
}
