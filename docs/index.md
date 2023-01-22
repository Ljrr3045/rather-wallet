# RatherWallet

## MasterChefVersion

```solidity
enum MasterChefVersion {
  V1,
  V2
}
```

## DepositETH

```solidity
event DepositETH(uint256 _date, uint256 _amount)
```

## WithdrawETH

```solidity
event WithdrawETH(uint256 _date, uint256 _amount)
```

## DepositToken

```solidity
event DepositToken(uint256 _date, address _token, uint256 _amount)
```

## WithdrawToken

```solidity
event WithdrawToken(uint256 _date, address _token, uint256 _amount)
```

## InvestInMiningProgram

```solidity
event InvestInMiningProgram(uint256 _date, address _tokenA, address _tokenB, string _version)
```

## WithdrawInMiningProgram

```solidity
event WithdrawInMiningProgram(uint256 _date, address _tokenA, address _tokenB, string _version)
```

## constructor

```solidity
constructor(address _routerV2, address _masterChefV1, address _masterChefV2) public
```

### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _routerV2 | address | Sushiswap Router V2 address |
| _masterChefV1 | address | Sushiswap MasterChef V1 address |
| _masterChefV2 | address | Sushiswap MasterChef V2 address |

## investInMiningProgram

```solidity
function investInMiningProgram(address _tokenA, address _tokenB, enum RatherWallet.MasterChefVersion _masterChefVersion) external
```

Function used to invest funds from the smart wallet in the liquidity mining program
        @dev only the owner can execute this action
        @param _tokenA address of the first token
        @param _tokenA address of the second token
        @param _masterChefVersion version of masterChef to use

## withdrawInMiningProgram

```solidity
function withdrawInMiningProgram(address _tokenA, address _tokenB, enum RatherWallet.MasterChefVersion _masterChefVersion) external
```

Function used to withdraw funds from the smart wallet in the liquidity mining program
        @dev only the owner can execute this action
        @param _tokenA address of the first token
        @param _tokenA address of the second token
        @param _masterChefVersion version of masterChef to use

## depositToken

```solidity
function depositToken(address _token, uint256 _amount) external
```

Function used to deposit token to the smart wallet
        @dev only the owner can execute this action
        @param _token address of the token to deposit
        @param _amount token amount to deposit

## withdrawToken

```solidity
function withdrawToken(address _token, uint256 _amount) external
```

Function used to withdraw token to the smart wallet
        @dev only the owner can execute this action
        @param _token address of the token to withdraw
        @param _amount token amount to withdraw

## depositETH

```solidity
function depositETH() external payable
```

Function used to deposit ETH to the smart wallet
        @dev only the owner can execute this action
        @dev function of type payable

## withdrawETH

```solidity
function withdrawETH(uint256 _amount) external
```

Function used to withdraw ETH to the smart wallet
        @dev only the owner can execute this action
        @param _amount ETH amount to withdraw

## receive

```solidity
receive() external payable
```

Function that allows the smart wallet to receive direct transfers of ETH
        @dev if the transfer comes from an address other than the WETH contract, all the deposited ETH is 
        converted to WETH. This is done to more easily handle the movements of adding liquidity in pools

# DefiManagement

## routerV2

```solidity
contract IUniswapV2Router routerV2
```

## factoryV2

```solidity
contract IUniswapV2Factory factoryV2
```

## masterChefV1

```solidity
contract IMasterChefV1 masterChefV1
```

## masterChefV2

```solidity
contract IMasterChefV2 masterChefV2
```

## PoolMasterChefData

```solidity
struct PoolMasterChefData {
  uint256 deposit;
  uint256 pid;
  bool previusDeposit;
}
```

## poolDepositInMasterChefV1

```solidity
mapping(address => struct DefiManagement.PoolMasterChefData) poolDepositInMasterChefV1
```

## poolDepositInMasterChefV2

```solidity
mapping(address => struct DefiManagement.PoolMasterChefData) poolDepositInMasterChefV2
```

## AddLiquidity

```solidity
event AddLiquidity(uint256 _date, address _tokenA, address _tokenB, uint256 _amount)
```

## RemoveLiquidity

```solidity
event RemoveLiquidity(uint256 _date, address _tokenA, address _tokenB, uint256 _amount)
```

## DepositInMasterChef

```solidity
event DepositInMasterChef(uint256 _date, uint256 _pid, uint256 _amount, string _version)
```

## WithdrawInMasterChef

```solidity
event WithdrawInMasterChef(uint256 _date, uint256 _pid, uint256 _amount, string _version)
```

## constructor

```solidity
constructor(address _routerV2, address _masterChefV1, address _masterChefV2) public
```

### Parameters

| Name | Type | Description |
| ---- | ---- | ----------- |
| _routerV2 | address | Sushiswap Router V2 address |
| _masterChefV1 | address | Sushiswap MasterChef V1 address |
| _masterChefV2 | address | Sushiswap MasterChef V2 address |

## _addLiquidity

```solidity
function _addLiquidity(address _tokenA, address _tokenB) internal
```

Function to add liquidity to a pool of tokens
        @param _tokenA address of the first token
        @param _tokenA address of the second token

## _removeLiquidity

```solidity
function _removeLiquidity(address _tokenA, address _tokenB) internal
```

Function to remove liquidity to a pool of tokens
        @param _tokenA address of the first token
        @param _tokenA address of the second token

## _wrapETH

```solidity
function _wrapETH() internal
```

Function to wrap ETH

## _unWrapETH

```solidity
function _unWrapETH(uint256 _amount) internal
```

Function to unwrap ETH
        @param _amount amount to unwrap

## _depositInMasterChefV1

```solidity
function _depositInMasterChefV1(address _tokenA, address _tokenB) internal
```

Function to add liquidity in the mining program
        @dev Works with MasterChef V1
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool

## _withdrawInMasterChefV1

```solidity
function _withdrawInMasterChefV1(address _tokenA, address _tokenB) internal
```

Function to withdraw liquidity in the mining program
        @dev Works with MasterChef V1
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool

## _depositInMasterChefV2

```solidity
function _depositInMasterChefV2(address _tokenA, address _tokenB) internal
```

Function to add liquidity in the mining program
        @dev Works with MasterChef V2
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool

## _withdrawInMasterChefV2

```solidity
function _withdrawInMasterChefV2(address _tokenA, address _tokenB) internal
```

Function to withdraw liquidity in the mining program
        @dev Works with MasterChef V2
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool

# IMasterChefV1

## PoolInfo

```solidity
struct PoolInfo {
  contract IERC20 lpToken;
  uint256 allocPoint;
  uint256 lastRewardBlock;
  uint256 accSushiPerShare;
}
```

## poolLength

```solidity
function poolLength() external view returns (uint256)
```

## deposit

```solidity
function deposit(uint256 _pid, uint256 _amount) external
```

## withdraw

```solidity
function withdraw(uint256 _pid, uint256 _amount) external
```

## poolInfo

```solidity
function poolInfo(uint256 _pid) external view returns (struct IMasterChefV1.PoolInfo)
```

# IMasterChefV2

## poolLength

```solidity
function poolLength() external view returns (uint256)
```

## deposit

```solidity
function deposit(uint256 _pid, uint256 _amount, address _to) external
```

## withdraw

```solidity
function withdraw(uint256 _pid, uint256 _amount, address _to) external
```

## lpToken

```solidity
function lpToken(uint256 _pid) external view returns (contract IERC20)
```

# IUniswapV2Factory

## getPair

```solidity
function getPair(address token0, address token1) external view returns (address)
```

# IUniswapV2Pair

## token0

```solidity
function token0() external view returns (address)
```

## token1

```solidity
function token1() external view returns (address)
```

## getReserves

```solidity
function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast)
```

## swap

```solidity
function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes data) external
```

# IUniswapV2Router

## factory

```solidity
function factory() external pure returns (address)
```

## WETH

```solidity
function WETH() external pure returns (address)
```

## getAmountsOut

```solidity
function getAmountsOut(uint256 amountIn, address[] path) external view returns (uint256[] amounts)
```

## swapExactTokensForTokens

```solidity
function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] path, address to, uint256 deadline) external returns (uint256[] amounts)
```

## swapExactTokensForETH

```solidity
function swapExactTokensForETH(uint256 amountIn, uint256 amountOutMin, address[] path, address to, uint256 deadline) external returns (uint256[] amounts)
```

## swapExactETHForTokens

```solidity
function swapExactETHForTokens(uint256 amountOutMin, address[] path, address to, uint256 deadline) external payable returns (uint256[] amounts)
```

## addLiquidity

```solidity
function addLiquidity(address tokenA, address tokenB, uint256 amountADesired, uint256 amountBDesired, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB, uint256 liquidity)
```

## removeLiquidity

```solidity
function removeLiquidity(address tokenA, address tokenB, uint256 liquidity, uint256 amountAMin, uint256 amountBMin, address to, uint256 deadline) external returns (uint256 amountA, uint256 amountB)
```

## addLiquidityETH

```solidity
function addLiquidityETH(address token, uint256 amountTokenDesired, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external payable returns (uint256 amountToken, uint256 amountETH, uint256 liquidity)
```

## removeLiquidityETH

```solidity
function removeLiquidityETH(address token, uint256 liquidity, uint256 amountTokenMin, uint256 amountETHMin, address to, uint256 deadline) external returns (uint256 amountToken, uint256 amountETH)
```

# IWETH9

## deposit

```solidity
function deposit() external payable
```

## withdraw

```solidity
function withdraw(uint256 wad) external
```