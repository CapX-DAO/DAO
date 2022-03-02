// SPDX-License-Identifier: agpl-3.0
pragma solidity <= 0.8.4;
pragma abicoder v2;

interface IVotingStrategy {
  function getVotingPowerAt(address user, uint256 blockNumber) external view returns (uint256);
}
