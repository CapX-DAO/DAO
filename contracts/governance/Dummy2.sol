// SPDX-License-Identifier: agpl-3.0

pragma solidity <= 0.8.4;
import {Ownable} from "../../dependencies/open-zeppelin/Ownable.sol";

contract Dummy2 is Ownable{
    uint256 val=0;
    function Setval(uint256 v) public payable{
        assert(msg.sender==owner());
        val = v;
    }

    function getval() public view returns (uint256){
        return val;
    }

}