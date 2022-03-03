# Executor #

Validate Proposal creations/ cancellation

Validate Vote Quorum and Vote success on proposal

Queue, Execute, Cancel, successful proposals' transactions.

Executor Contract constructor makes call to ExecutorWithTimelock(admin, delay, gracePeriod, minimumDelay, maximumDelay) and ProposalValidator(propositionThreshold, voteDuration, voteDifferential, minimumQuorum) contract constructor


### Executor (short) ###
It will control the whole Aave protocol v1, the token distributor used in v1, the contract collecting the fees of v1, the Reserve Ecosystem of AAVE and any change in this timelock itself

- admin (the only address enable to interact with this executor): Aave Governance v2
- delay (time between a proposals passes and its actions get executed): 1 day
- grace period (time after the delay during which the proposal can be executed): 5 days
- proposition threshold: 0.5%
- voting duration: 3 days
- vote differential: 0.5%
- quorum: 2%

### Executor (long) ###

It will control the upgradeability of the AAVE token, the stkAAVE, any change in the parameters of the Governance v2 and any change in the parameters of this timelock itself

- admin: Aave Governance v2
- delay: 7 days
- grace period: 5 days
- proposition threshold: 2%
- voting duration: 10 days
- vote differential: 15%
- quorum: 20%