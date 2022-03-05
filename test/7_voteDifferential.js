const ERC20CRV = artifacts.require("ERC20CRV");
const VotingEscrow = artifacts.require("VotingEscrow");
const GovernanceStrategy = artifacts.require("GovernanceStrategy");
const AaveGovernanceV2 = artifacts.require("AaveGovernanceV2");
const Executor = artifacts.require("Executor");
const Dummy1 = artifacts.require("Dummy1");
const helper = require("../utils");

// we have three voters: voter1, voter2, voter3.
// voter2 and voter3 - true, voter1 = false
// vote differential is set to 15%, so the proposal will not be succeeded because vp2 + vp3 - vp1 ka percentage is less than 15%

// voting power of deployer: 17006662
// voting power of 1: 17006658
// voting power of 2: 25509987
// voting power of 3: 8503329

contract("AaveGovernanceV2", ([deployer, voter1, voter2, voter3]) => {
  let token;
  let escrow;
  let gstrat;
  let aaveV2;
  let exec;
  let dummy1;
  let address = deployer;
  let votingDelay = 0;
  let guardianAddr = deployer;
  let executors = [deployer];

  let value = 1303030303; // it is the current deployer balance
  let value1 = 303030303;
  let value2 = 503030303;
  let value3 = 203030303;
  let unlockTime = new Date();
  unlockTime.setDate(unlockTime.getDate() + 100);
  unlockTime = parseInt(unlockTime.getTime() / 1000);

  let admin;
  let delay;
  let gracePeriod;
  let minimumDelay;
  let maximumDelay;
  let propositionThreshold;
  let voteDuration;
  let voteDifferential;
  let minimumQuorum;
  let result;

  let targets;
  let oldCount;
  let newCount;

  let id;
  let vote1;
  let vote2;
  let vote3;

  // total voting power = 68044896

  describe("vote differential", async () => {
    it("checks if the ERC20CRV contract deploys corectly and transfers amount to the voter accounts", async () => {
      token = await ERC20CRV.new("Token", "TOK", 18);

      await token.transfer(voter1, value1);
      await token.transfer(voter2, value2);
      await token.transfer(voter3, value3);

      assert(token.address != "", "CRV not deployed correctly");

      let balance1 = await token.balanceOf(voter1);
      let balance2 = await token.balanceOf(voter2);
      let balance3 = await token.balanceOf(voter3);

      assert(balance1.toNumber() === value1, "Not able to transfer the amount");
      assert(balance2.toNumber() === value2, "Not able to transfer the amount");
      assert(balance3.toNumber() === value3, "Not able to transfer the amount");

      timestamp = new Date();
      timestamp = parseInt(timestamp.getTime() / 1000);

      console.log("Remaining time: ", unlockTime - timestamp);
      let balance = await token.balanceOf(deployer);
      console.log("balance:", balance.toNumber());

      console.log("balance of voter1", balance1.toNumber());
      assert(balance.toNumber() === value - value1 - value2 - value3);
    });

    it("checks if the Voting Escrow contract has deployed correcly", async () => {
      escrow = await VotingEscrow.new(token.address, "Token", "TOK", 18);
      assert(escrow.address != "", "Voting Escrow has not deployed correclty");
    });

    describe("checks the overall integration for testing", async () => {
      it("checks if able to create the lock", async () => {
        value = value - value1 - value2 - value3;
        await token.approve(escrow.address, value);
        await token.approve(escrow.address, value1, { from: voter1 });
        await token.approve(escrow.address, value2, { from: voter2 });
        await token.approve(escrow.address, value3, { from: voter3 });
        await escrow.createLock(value, unlockTime);
        await escrow.createLock(value1, unlockTime, { from: voter1 });
        await escrow.createLock(value2, unlockTime, { from: voter2 });
        await escrow.createLock(value3, unlockTime, { from: voter3 });

        console.log("Deployer address", deployer.toString());
        console.log("Voter1 address", voter1.toString());

        balance_dp = await escrow.balanceOf(deployer);
        console.log("vp of deployer", balance_dp.toNumber());

        balance = await escrow.balanceOf(voter1);
        console.log("vp of voter1", balance.toNumber());
      });

      it("checks if able to deploy governance strategy", async () => {
        gstrat = await GovernanceStrategy.new(escrow.address);
        assert(
          gstrat.address != "",
          "Governance strategy not deploying correctly"
        );
      });

      it("checks if the balance of the user from voting escrow and governance strategy are the same", async () => {
        let blkNumber = await gstrat.getBlockNumber();
        let balance1, balance2, balance3, balance4, balance5, balance6;

        balance1 = await gstrat.getVotingPowerAt(voter1, blkNumber.toNumber());
        balance2 = await escrow.balanceOfAt(voter1, blkNumber.toNumber());

        console.log("vp1: ", balance1.toNumber());
        balance3 = await gstrat.getVotingPowerAt(voter2, blkNumber.toNumber());
        balance4 = await escrow.balanceOfAt(voter2, blkNumber.toNumber());

        console.log("vp2: ", balance3.toNumber());

        balance5 = await gstrat.getVotingPowerAt(voter3, blkNumber.toNumber());
        balance6 = await escrow.balanceOfAt(voter3, blkNumber.toNumber());

        console.log("vp3: ", balance5.toNumber());
        assert(
          balance1.toNumber() === balance2.toNumber(),
          "Function is not working correctly"
        );
        assert(
          balance3.toNumber() === balance4.toNumber(),
          "Function is not working correctly"
        );
        assert(
          balance5.toNumber() === balance6.toNumber(),
          "Function is not working correctly"
        );

        // will set proposition threshold to be some percentage of this value
        let tvp = await escrow.totalSupply();
        console.log("Total voting power is: ", tvp.toNumber());
      });

      it("checks if able to deploy aaveGovernance strategy", async () => {
        aaveV2 = await AaveGovernanceV2.new(
          gstrat.address,
          votingDelay,
          guardianAddr,
          executors
        );
        assert(
          aaveV2.address != "",
          "Not able to deploy the AaveGovernanceV2 contract"
        );
      });

      it("checks if able to deploy Executor with given values", async () => {
        admin = aaveV2.address;
        delay = 0;
        gracePeriod = 300;
        minimumDelay = 0;
        maximumDelay = 300;
        // setting to 15% because the lowest voting power is 12.5% of total voting power
        propositionThreshold = 0;
        voteDuration = 5;
        voteDifferential = 1500;
        minimumQuorum = 0;

        exec = await Executor.new(
          admin,
          delay,
          gracePeriod,
          minimumDelay,
          maximumDelay,
          propositionThreshold,
          voteDuration,
          voteDifferential,
          minimumQuorum
        );
        assert(exec.address != "", "Not able to deploy the executor contract");
      });

      it("checks if we are able to authorize the executor", async () => {
        try {
          await aaveV2.authorizeExecutors([exec.address]);
          assert(true);
        } catch (err) {
          console.err(err);
          assert(
            false,
            "Function should have worked with the given executor address"
          );
        }

        // will return true or false depending on how the function above worked
        result = await aaveV2.isExecutorAuthorized(exec.address);
        assert(result, "The executor is not authorized");
      });

      it("checks deployment of dummy contract and tranferring of ownership", async () => {
        // deploying a dummy contract for proposal:
        // positive test
        dummy1 = await Dummy1.new();
        try {
          await dummy1.transferOwnership(exec.address);
          assert(true);
        } catch (err) {
          assert(false, "Function should have worked");
        }

        let add = exec.address;
        let newOwner = await dummy1.owner();
        assert(
          newOwner.toString() == add.toString(),
          "Executor is not the owner"
        );
      });

      it("creates a new proposal for testing for deployer", async () => {
        targets = [dummy1.address];
        oldCount = await aaveV2.getProposalsCount();

        await aaveV2.create(
          exec.address,
          targets,
          [0],
          ["setVal(uint256)"],
          [
            "0x0000000000000000000000000000000000000000000000000000000000000005",
          ],
          [false],
          "0x7465737400000000000000000000000000000000000000000000000000000000"
        );
        newCount = await aaveV2.getProposalsCount();
        assert(
          newCount.toNumber() - oldCount.toNumber() == 1,
          "Proposal was not created"
        );
      });

      it("trying to submit vote on a proposal and prints the vote", async () => {
        // to get the id of the most recent proposal, can use any other id for testing as well
        id = newCount.toNumber() - 1;

        vote1 = false;
        vote2 = true;
        vote3 = true;
        // vote for the proposal
        // should work for our case, may change to a negative test with wrong values later

        // submits vote for voter1
        try {
          await aaveV2.submitVote(id, vote1, { from: voter1 });
          assert(true);
        } catch (err) {
          assert(false);
        }

        // submits vote for voter2
        try {
          await aaveV2.submitVote(id, vote2, { from: voter2 });
          assert(true);
        } catch (err) {
          assert(false);
        }

        // submits vote for voter3
        try {
          await aaveV2.submitVote(id, vote3, { from: voter3 });
          assert(true);
        } catch (err) {
          assert(false);
        }
      });

      it("trying to check the voting differential functionality", async () => {
        blockNumber = await gstrat.getBlockNumber();
        console.log("Current block number now:", blockNumber.toNumber());

        // this should fail, negative test
        // increase block number by 1
        try {
          await aaveV2.queue(id);
          assert(
            false,
            "This should not have worked..something wrong in the function "
          );
        } catch (err) {
          assert(true);
        }

        // // increases block number by 1 again
        let newBlock = await gstrat.getBlockNumber();
        console.log("New block number is: ", newBlock.toNumber());

        // according to voting duration, this is the right time, but it will not go to queue because of quorum
        try {
          await aaveV2.queue(id);
          assert(false, "Should not have passed because the quorum is more");
        } catch (err) {
          assert(true, "Something wrong");
        }
      });
    });
  });
});
