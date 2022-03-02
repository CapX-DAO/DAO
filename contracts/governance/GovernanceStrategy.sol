// SPDX-License-Identifier: agpl-3.0
pragma solidity <= 0.8.4;
pragma abicoder v2;

import {IGovernanceStrategy} from '../interfaces/IGovernanceStrategy.sol';
import {VotingEscrow} from '../VotingEscrow.sol';
import {IGovernancePowerDelegationToken} from '../interfaces/IGovernancePowerDelegationToken.sol';

/**
 * @title Governance Strategy contract
 * @dev Smart contract containing logic to measure users' relative power to propose and vote.
 * User Power = User Power from Aave Token + User Power from stkAave Token.
 * User Power from Token = Token Power + Token Power as Delegatee [- Token Power if user has delegated]
 * Two wrapper functions linked to Aave Tokens's GovernancePowerDelegationERC20.sol implementation
 * - getPropositionPowerAt: fetching a user Proposition Power at a specified block
 * - getVotingPowerAt: fetching a user Voting Power at a specified block
 * @author Aave
 **/


contract GovernanceStrategy is IGovernanceStrategy {
  address public immutable VECRV;

  // /**
  //  * @dev Constructor, register tokens used for Voting and Proposition Powers.
  //  * @param aave The address of the AAVE Token contract.
  //  * @param stkAave The address of the stkAAVE Token Contract
  //  **/
  constructor(address vecrv) {
    VECRV = vecrv;
  }

  function get_block_number() public view returns (uint256) {
    return block.number;
  }

  /**
   * @dev Returns the total supply of Proposition Tokens Available for Governance
   * = AAVE Available for governance      + stkAAVE available
   * The supply of AAVE staked in stkAAVE are not taken into account so:
   * = (Supply of AAVE - AAVE in stkAAVE) + (Supply of stkAAVE)
   * = Supply of AAVE, Since the supply of stkAAVE is equal to the number of AAVE staked
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalPropositionSupplyAt(uint256 blockNumber) public view override returns (uint256) {
    return VotingEscrow(VECRV).totalSupplyAt(blockNumber);
  }


  /**
   * @dev Returns the total supply of Outstanding Voting Tokens 
   * @param blockNumber Blocknumber at which to evaluate
   * @return total supply at blockNumber
   **/
  function getTotalVotingSupplyAt(uint256 blockNumber) public view override returns (uint256) {
    return getTotalPropositionSupplyAt(blockNumber);
  }

  /**
   * @dev Returns the Proposition Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Proposition Power
   * @return Power number
   **/
  function getPropositionPowerAt(address user, uint256 blockNumber)
    public
    view
    override
    returns (uint256)
  {
      return VotingEscrow(VECRV).balanceOfAt(user, blockNumber);
  }

  /**
   * @dev Returns the Vote Power of a user at a specific block number.
   * @param user Address of the user.
   * @param blockNumber Blocknumber at which to fetch Vote Power
   * @return Vote number
   **/
  function getVotingPowerAt(address user, uint256 blockNumber)
    public
    view
    override
    returns (uint256)
  {
     return VotingEscrow(VECRV).balanceOfAt(user, blockNumber);
  }
}
