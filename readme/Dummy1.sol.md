## Dummy1.sol
Dummy contract to test execution of proposal

### Variables
- `uint256 val=0`:

   Variable for which integer value to be set.



### Functions
**Setval :**

```solidity 
function setVal(uint256 v) public
```

Inputs required

- `v`- integer value

Functionality

- Method sets value of variable val

- Method is defined with payable access modifier as some amount of ethers need to be sent while calling SetVal method.

**getVal :**

```solidity 
function getVal public view returns (uint256)
```
Functionality

- Method returns integer value of the val variable

