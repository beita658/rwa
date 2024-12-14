// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6;
import "./SafeMath.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./Initializable.sol";

import "./console.sol";
// import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
interface ERC20 {
   
      function getalreadtprofit(address owner) external view returns (uint256);
      function _balancesU(address owner) external view returns (uint256);

}
interface IUniswapV2Pair {

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
    external
    view
    returns (
        uint112 reserve0,
        uint112 reserve1,
        uint32 blockTimestampLast
    );

}
interface IPancakeFactory {
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}
interface IRouter{
       function WETH() external pure returns (address);
    function factory() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
         function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
contract SmartDisPatchInitializable is Ownable, Initializable {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public constant MAX_SUPPLY_TOKEN = 500;
    // The address of the smart chef factory
    address public SMART_DISPATCH_FACTORY;
    mapping(address => uint256) public is_owner;
    uint256 public _totalSupply;
    mapping(address => uint256) public _balances;
    mapping(address => PoolInfo) public poolInfos;
    address[] public rewardTokens;

    struct PoolInfo {
        bool enable;
        IERC20 rewardToken;
        uint256 reserve;
        uint256 rewardLastStored;
        mapping(address => uint256) userRewardStored;
        mapping(address => uint256) newReward;
        mapping(address => uint256) claimedReward;
    }
   
   address public token=0x6B2d313e230e1fd725b18aF5Ff417AF9CB3C2AA3;
    mapping(address => uint256)public alreadyprofit;
    mapping(address => uint256)public alreadyU;
    event AddPool(address indexed token);
    event PoolEnabled(address indexed token, bool enable);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(
        address indexed user,
        address indexed token,
        uint256 reward
    );
    
 bool internal locked;
    constructor() {
        SMART_DISPATCH_FACTORY = msg.sender;
    }
    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }

    function initialize(address[] memory rewardTokens_, address admin_)
        external
        initializer
    {
        require(msg.sender == SMART_DISPATCH_FACTORY, "Not factory");
        rewardTokens = rewardTokens_;
        for (uint256 i = 0; i != rewardTokens_.length; i++) {
            poolInfos[rewardTokens_[i]].rewardToken = IERC20(rewardTokens_[i]);
            poolInfos[rewardTokens_[i]].enable = true;
        }

        transferOwnership(admin_);
    }

    modifier updateDispatch(address account) {
        for (uint256 i = 0; i != rewardTokens.length; i++) {
            address token = rewardTokens[i];
            PoolInfo storage pool = poolInfos[token];
            if (pool.enable) {
                pool.rewardLastStored = rewardPer(pool);
                if (pool.rewardLastStored > 0) {
                    uint256 balance = pool.rewardToken.balanceOf(address(this));
                    pool.reserve = balance;
                    if (account != address(0)) {
                        pool.newReward[account] = available(token, account);
                        pool.userRewardStored[account] = pool.rewardLastStored;
                    }
                }
            }
        }
        _;
    }
    function addcontract(address token,uint256 _value) external onlyOwner {
           is_owner[token] = _value;
    }
    function addPool(address token) external onlyOwner {
        require(
            address(poolInfos[token].rewardToken) == address(0),
            "pool is exits"
        );
        require(
            rewardTokens.length < MAX_SUPPLY_TOKEN,
            "supported token types exceed the limit"
        );
        poolInfos[token].rewardToken = IERC20(token);
        poolInfos[token].enable = true;
        rewardTokens.push(token);

        emit AddPool(token);
    }

    function enablePool(address token, bool enable) external onlyOwner {
        require(
            address(poolInfos[token].rewardToken) != address(0),
            "pool not is exits"
        );
        poolInfos[token].rewardToken = IERC20(token);
        poolInfos[token].enable = enable;
         emit PoolEnabled(token, enable);
    }

    function getAllSupplyTokens() public view returns (address[] memory) {
        return rewardTokens;
    }

    function claimedReward(address token, address account)
        public
        view
        returns (uint256)
    {
        PoolInfo storage pool = poolInfos[token];
        return pool.claimedReward[account];
    }
    function withdrawtoken(address _token,uint256 _amount)public onlyOwner noReentrant{
         PoolInfo storage pool = poolInfos[_token];
        pool.rewardToken.safeTransfer(msg.sender, _amount);
    }
    function lastReward(PoolInfo storage pool) private view returns (uint256) {
        if (_totalSupply == 0) {
            return 0;
        }
        uint256 balance = pool.rewardToken.balanceOf(address(this));
        return balance.sub(pool.reserve);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    function rewardPer(PoolInfo storage pool) private view returns (uint256) {
        if (totalSupply() == 0) {
            return pool.rewardLastStored;
        }
        return
            pool.rewardLastStored.add(
                lastReward(pool).mul(1e18).div(totalSupply())
            );
    }

    function stake(address account, uint256 amount)
        external noReentrant
        updateDispatch(account) 
    {
        IERC20(token).safeTransferFrom(account,address(this), amount);
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Staked(account, amount);
    }

    function withdraw(address account, uint256 amount)
        external noReentrant
        updateDispatch(account)
    {
     
   
        if (amount == 0) {
            return;
        }
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
         IERC20(token).safeTransfer(account, amount);
        emit Withdrawn(account, amount);
    }

    function available(address token, address account)
        public
        view
        returns (uint256)
    {
      
        PoolInfo storage pool = poolInfos[token];
        uint256 reward=
            balanceOf(account)
                .mul(rewardPer(pool).sub(pool.userRewardStored[account]))
                .div(1e18)
                .add(pool.newReward[account]);
  
           return reward;
    }

    function claim(address token) external noReentrant updateDispatch(msg.sender) {
        PoolInfo storage pool = poolInfos[token];
        uint256 reward = available(token, msg.sender);
        if (reward <= 0) {
            return;
        }
        pool.reserve = pool.reserve.sub(reward);
        pool.newReward[msg.sender] = 0;

        pool.claimedReward[msg.sender] = pool.claimedReward[msg.sender].add(
            reward
        );
        alreadyprofit[msg.sender] += reward;
        pool.rewardToken.safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, token, reward);
    }
}