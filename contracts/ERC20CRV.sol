// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "../dependencies/open-zeppelin/ERC20.sol";
import "../dependencies/open-zeppelin/IERC20.sol";
import "../dependencies/open-zeppelin/IERC20Metadata.sol";
contract ERC20CRV is IERC20, IERC20Metadata{
    event UpdateMiningParameters(uint256 time , uint256 rate , uint256 supply);
    event SetMinter(address minter);
    event SetAdmin(address admin);

    string _name;
    string _symbol;
    uint8 _decimals;

    struct mintinfo {
        uint256 blockNumber;
        int256 value;
        
    }

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowances;
    uint256 supply;
    mapping(uint256 => mintinfo) mintedAtBlockNumber;
    uint256 mintedAtBlockNumberLength;

    address public minter;
    address public admin;

    // General constants
    uint256 constant YEAR = 86400 * 365;

    // Allocation:
    // =========
    // * shareholders - 30%
    // * emplyees - 3%
    // * DAO-controlled reserve - 5%
    // * Early users - 5%
    // == 43% ==
    // left for inflation: 57%

    // Supply parameters
    uint256 constant INITIAL_SUPPLY = 1_303_030_303;
    uint256 constant INITIAL_RATE = 274_815_283 * 10 ** 18 / YEAR;  // leading to 43% premine
    uint256 constant RATE_REDUCTION_TIME = YEAR;
    uint256 constant RATE_REDUCTION_COEFFICIENT = 1189207115002721024;  // 2 ** (1/4) * 1e18
    uint256 constant RATE_DENOMINATOR = 10 ** 18;
    uint256 constant INFLATION_DELAY = 86400;
    address constant ZERO_ADDRESS = address(0);

    // Supply variables
    int128 public miningEpoch;
    uint256 public startEpochTime;
    uint256 public rate;

    uint256 startEpochSupply;


    constructor(string memory name_ , string memory symbol_ , uint8  decimals_) {
        /// @notice Contract constructor
        /// @param _name Token full name
        /// @param _symbol Token symbol
        /// @param _decimals Number of decimals for token


        uint256 initSupply = INITIAL_SUPPLY * 10 ** _decimals;
        _name = name_;
        _symbol = symbol_;
        _decimals = decimals_;
        balances[msg.sender] = initSupply;
        supply = initSupply;
        admin = msg.sender;
        emit Transfer(ZERO_ADDRESS, msg.sender, initSupply);

        startEpochTime = block.timestamp + INFLATION_DELAY - RATE_REDUCTION_TIME;
        miningEpoch = -1;
        rate = 0;
        startEpochSupply = initSupply;
        
    }

    function name() public view virtual override returns (string memory) {
        /// @notice Return token name
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return supply;
    }

    function balanceOf(address _owner) public view virtual override returns (uint256) {
        return balances[_owner];
    }

    function _updateMiningParameters() private {
        /// @dev Update mining rate and supply at the start of the epoch
        /// Any modifying mining call must also call this

        uint256 _rate = rate;
        uint256 _startEpochSupply = startEpochSupply;

        startEpochTime += RATE_REDUCTION_TIME;
        miningEpoch += 1;

        if (_rate == 0) {
            _rate = INITIAL_RATE;
        } else {
            _startEpochSupply += _rate * RATE_REDUCTION_TIME;
            startEpochSupply = _startEpochSupply;
            _rate = _rate * RATE_DENOMINATOR / RATE_REDUCTION_COEFFICIENT;
        }

        rate = _rate;

        emit UpdateMiningParameters(block.timestamp, _rate, _startEpochSupply);
    }

    function totalSupplyAt(uint256 blockNumber) public view virtual returns (uint256) {
        int256 numToSubtract = 0;
        for (uint256 index = 0; index < mintedAtBlockNumberLength; index++) {
            if (mintedAtBlockNumber[mintedAtBlockNumberLength - index - 1].blockNumber >= blockNumber) {
                numToSubtract += mintedAtBlockNumber[mintedAtBlockNumberLength - index - 1].value;
            } else {
                break;
            }
        }
        return intToUint(uintToInt(supply) - numToSubtract);
    }

    function updateMiningParameters() public {
        /// @notice Update mining rate and supply at the start of the epoch
        /// @dev Callable by any address, but only once per epoch
        /// Total supply becomes slightly larger if this function is called late
        require(block.timestamp >= startEpochTime + RATE_REDUCTION_TIME, "too soon!");
        _updateMiningParameters();
    }

    function startEpochTimeWrite() public returns (uint256) {
        /// @notice Get timestamp of the current mining epoch start
        /// while simultaneously updating mining parameters
        /// @return Timestamp of the epoch
        if (block.timestamp >= startEpochTime + RATE_REDUCTION_TIME) {
            _updateMiningParameters();
            return startEpochTime;
        } else {
            return startEpochTime;
        }
    }

    function futureEpochTimeWrite() public returns (uint256) {
        /// @notice Get timestamp of the next mining epoch start
        /// while simultaneously updating mining parameters
        /// @return Timestamp of the next epoch
        if (block.timestamp >= startEpochTime + RATE_REDUCTION_TIME) {
            _updateMiningParameters();
            return startEpochTime + RATE_REDUCTION_TIME;
        } else {
            return startEpochTime + RATE_REDUCTION_TIME;
        }
    }

    function _availableSupply() private view returns (uint256){
        return startEpochSupply + (block.timestamp - startEpochTime) * rate;
    }

    function availableSupply() public view returns (uint256) {
        /// @notice Current number of tokens in existence (claimed or unclaimed)
        /// @dev Callable by any address
        return _availableSupply();
    }


    function mintableInTimeframe(uint256 start,uint256 end) public view returns (uint256) {
        /// @notice How much supply is mintable from start timestamp till end timestamp
        /// @param start Start of the time interval (timestamp)
        /// @param end End of the time interval (timestamp)
        /// @return Tokens mintable from `start` till `end`
        require(start <= end, "start must be less than end");
        uint256 toMint = 0;
        uint256 currentEpochTime = startEpochTime;
        uint256 currentRate = rate;

        // Special case if end is in future (not yet minted) epoch
        if (end > currentEpochTime + RATE_REDUCTION_TIME) {
            currentEpochTime += RATE_REDUCTION_TIME;
            currentRate = currentRate * RATE_DENOMINATOR / RATE_REDUCTION_COEFFICIENT;
        }

        require(end <= currentEpochTime + RATE_REDUCTION_TIME, "end must be less than or equal to currentEpochTime + RATE_REDUCTION_TIME");

        for (uint256 i = 0; i < 999; i++) {  // Curve will not work in 1000 years. Darn!
            if (end >= currentEpochTime) {
                uint256 currentEnd = end;
                if (currentEnd > currentEpochTime + RATE_REDUCTION_TIME) {
                    currentEnd = currentEpochTime + RATE_REDUCTION_TIME;
                }

                uint256 currentStart = start;
                if (currentStart >= currentEpochTime + RATE_REDUCTION_TIME) {
                    break;  // We should never get here but what if...
                } else if (currentStart < currentEpochTime) {
                    currentStart = currentEpochTime;
                }

                toMint += currentRate * (currentEnd - currentStart);

                if (start >= currentEpochTime) {
                    break;
                }

            }
            currentEpochTime -= RATE_REDUCTION_TIME;
            currentRate = currentRate * RATE_REDUCTION_COEFFICIENT / RATE_DENOMINATOR;  // double-division with rounding made rate a bit less => good
            require(currentRate <= INITIAL_RATE, "currentRate must be less than or equal to INITIAL_RATE");
        }

        return toMint;
    }

    function setMinter(address _minter) public {
        /// @notice Set the minter address
        /// @dev Only callable once, when minter has not yet been set
        /// @param _minter Address of the minter
        require(msg.sender == admin, "only admin can set minter");
        require(minter == ZERO_ADDRESS, "minter can be set only once");
        minter = _minter;
        emit SetMinter(_minter);
    }

    function setAdmin(address _admin) public {
        /// @notice Set the new admin.
        /// @dev After all is set up, admin only can change the token name
        /// @param _admin New admin address
        require(msg.sender == admin, "only admin can set admin");
        admin = _admin;
        emit SetAdmin(_admin);
    }

    function allowance(address _owner , address _spender) public view override returns (uint256) {
        /// @notice Check the amount of tokens that an owner allowed to a spender
        /// @param _owner The address which owns the funds
        /// @param _spender The address which will spend the funds
        /// @return uint256 specifying the amount of tokens still available for the spender
        return allowances[_owner][_spender];
    }

    function transfer(address _to , uint256 value) public override returns (bool) {
        /// @notice Transfer `_value` tokens from `msg.sender` to `_to`
        /// @dev Vyper does not allow underflows, so the subtraction in
        /// this function will revert on an insufficient balance
        /// @param _to The address to transfer to
        /// @param _value The amount to be transferred
        /// @return bool success
        require(value > 0, "value must be greater than 0");
        require(msg.sender != _to, "cannot transfer to self");
        require(balanceOf(msg.sender) >= value, "insufficient balance");
        balances[msg.sender] -= value;
        balances[_to] += value;
        emit Transfer(msg.sender, _to, value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public override returns (bool) {
        /// @notice Transfer `_value` tokens from `_from` to `_to`
        /// @param _from address The address which you want to send tokens from
        /// @param _to address The address which you want to transfer to
        /// @param _value uint256 the amount of tokens to be transferred
        /// @return bool success
        require(_to != ZERO_ADDRESS, "cannot transfer to 0x0");
        require(_value > 0, "value must be greater than 0");
        require(allowances[_from][msg.sender] >= _value, "insufficient allowance");
        require(balances[_from] >= _value, "insufficient balance");
        balances[_from] -= _value; //////////////////////////////////////////////////////////////////////////////////////////////
        balances[_to] += _value;
        allowances[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender,uint256 _value) public override returns (bool) {
        /// @notice Approve `_spender` to transfer `_value` tokens on behalf of `msg.sender`
        /// @dev Approval may only be from zero -> nonzero or from nonzero -> zero in order
        /// to mitigate the potential
        /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        /// @param _spender The address which will spend the funds
        /// @param _value The amount of tokens to be spent
        /// @return bool success
        require(_value != 0 , "cannot approve to zero amount");
        allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;        
    }

    function uintToInt(uint num) private pure returns (int) {
    return int(num);
  }

  function intToUint(int num) private pure returns (uint) {
    return uint(num);
  }

    function mint(address _to, uint256 _value) public virtual returns (bool) {
        /// @notice Mint `_value` tokens and assign them to `_to`
        /// @dev Emits a Transfer event originating from 0x00
        /// @param _to The account that will receive the created tokens
        /// @param _value The amount that will be created
        /// @return bool success
        require(msg.sender != address(0), "ERC20: mint to the zero address");
        require(_to != ZERO_ADDRESS, "cannot mint to 0x0");
        require(_value > 0, "value must be greater than 0");
        require(msg.sender == admin, "Only Admin can mint");
        supply += _value;
        balances[_to] += _value;
        emit Transfer(ZERO_ADDRESS, _to, _value);
        mintedAtBlockNumber[mintedAtBlockNumberLength] = mintinfo(block.number,uintToInt(_value));
        mintedAtBlockNumberLength++;
        return true;
    }

    function burn(uint256 _value) public returns (bool) {
        /// @notice Burn `_value` tokens belonging to `msg.sender`
        /// @dev Emits a Transfer event with a destination of 0x00
        /// @param _value The amount that will be burned
        /// @return bool success
        require(msg.sender != address(0), "ERC20: mint to the zero address");
        require(_value > 0, "value must be greater than 0");
        require(balances[msg.sender] >= _value, "insufficient balance");
        balances[msg.sender] -= _value;
        supply -= _value;
        emit Transfer(msg.sender, ZERO_ADDRESS, _value);
        mintedAtBlockNumber[mintedAtBlockNumberLength] = mintinfo(block.number,(uintToInt(_value)*-1));
        mintedAtBlockNumberLength++;
        return true;
    }

    function setName(string memory name_, string memory symbol_) public {
        /// @notice Change the token name and symbol to `_name` and `_symbol`
        /// @dev Only callable by the admin account
        /// @param _name New token name
        /// @param _symbol New token symbol
        require(msg.sender == admin, "Only admin is allowed to change name");
        _name = name_;
        _symbol = symbol_;        
    }

}