// SPDX-License-Identifier: agpl-3.0

pragma solidity <= 0.8.4;
import {Ownable} from "../../dependencies/open-zeppelin/Ownable.sol";

contract Dummy1 is Ownable{
    uint256 val=0;
    function setVal(uint256 v) public {
        assert(msg.sender==owner());
        val = v;
    }

    function getVal() public view returns (uint256){
        return val;
    }

}