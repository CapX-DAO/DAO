contract Helper {

    function getBlockNumber() public view returns (uint256) {
        return block.number;
    }

    function getBlockTimestamp() public view returns (uint256){
        return block.timestamp;
    }
}