//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
    @title Defi Management
    @author ljrr3045
    @notice The main purpose of this contract is to handle all actions related to DeFi transactions (add liquidity, 
    invest in mining program, etc).
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IMasterChefV1.sol";
import "../interfaces/IMasterChefV2.sol";
import "../interfaces/IWETH9.sol";

contract DefiManagement {

    IUniswapV2Router internal routerV2;
    IUniswapV2Factory internal factoryV2;

    IMasterChefV1 internal masterChefV1;
    IMasterChefV2 internal masterChefV2;

// Structs and Mappings

    struct PoolMasterChefData {
        uint256 deposit;
        uint256 pid;
        bool previusDeposit;
    }

    mapping (address => PoolMasterChefData) public poolDepositInMasterChefV1;
    mapping (address => PoolMasterChefData) public poolDepositInMasterChefV2;

// Events

    event AddLiquidity(uint256 indexed _date, address _tokenA, address _tokenB, uint256 _amount);
    event RemoveLiquidity(uint256 indexed _date, address _tokenA, address _tokenB, uint256 _amount);
    event DepositInMasterChef(uint256 indexed _date, uint256 _pid, uint256 _amount, string _version);
    event WithdrawInMasterChef(uint256 indexed _date, uint256 _pid, uint256 _amount, string _version);

// Constructor

    /**
        @param _routerV2 Sushiswap Router V2 address
        @param _masterChefV1 Sushiswap MasterChef V1 address
        @param _masterChefV2 Sushiswap MasterChef V2 address
    */
    constructor(
        address _routerV2,
        address _masterChefV1,
        address _masterChefV2
    ) {
        routerV2 = IUniswapV2Router(_routerV2);
        factoryV2 = IUniswapV2Factory(routerV2.factory());

        masterChefV1 = IMasterChefV1(_masterChefV1);
        masterChefV2 = IMasterChefV2(_masterChefV2);
    }

// Liquidity Functions

    /**
        @notice Function to add liquidity to a pool of tokens
        @param _tokenA address of the first token
        @param _tokenA address of the second token
    */
    function _addLiquidity(address _tokenA, address _tokenB) internal {
        require(IERC20(_tokenA).balanceOf(address(this)) > 0, "DefiManagement: Insufficient TokenA Balance");
        require(IERC20(_tokenB).balanceOf(address(this)) > 0, "DefiManagement: Insufficient TokenB Balance");

        require(
            IERC20(_tokenA).approve(address(routerV2), IERC20(_tokenA).balanceOf(address(this))), 
            "DefiManagement: TokenA approval error"
        );
        require(
            IERC20(_tokenB).approve(address(routerV2), IERC20(_tokenB).balanceOf(address(this))), 
            "DefiManagement: TokenB approval error"
        );

        (,, uint256 _liquidity) = routerV2.addLiquidity(
            _tokenA,
            _tokenB,
            IERC20(_tokenA).balanceOf(address(this)),
            IERC20(_tokenB).balanceOf(address(this)),
            1,
            1,
            address(this),
            block.timestamp
        );

        require(_liquidity > 0, "DefiManagement: Failed to add liquidity");

        emit AddLiquidity(block.timestamp, _tokenA, _tokenB, _liquidity);
    }

    /**
        @notice Function to remove liquidity to a pool of tokens
        @param _tokenA address of the first token
        @param _tokenA address of the second token
    */
    function _removeLiquidity(address _tokenA, address _tokenB) internal {
        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)) > 0, 
            "DefiManagement: Insufficient SLP Balance"
        );

        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).approve(
                address(routerV2), 
                IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this))
            ),
            "DefiManagement: SLP approval error"
        );

        emit RemoveLiquidity(
            block.timestamp, 
            _tokenA, 
            _tokenB, 
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this))
        );

        routerV2.removeLiquidity(
            _tokenA,
            _tokenB,
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)),
            1,
            1,
            address(this),
            block.timestamp
        );

        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)) == 0, 
            "DefiManagement: Failed to remove liquidity"
        );
    }

// Wraps Functions

    /**
        @notice Function to wrap ETH
    */
    function _wrapETH() internal{
        require(msg.value > 0, "DefiManagement: Insufficient amount to wrap");

        IWETH9(routerV2.WETH()).deposit{value : msg.value}();
    }

    /**
        @notice Function to unwrap ETH
        @param _amount amount to unwrap
    */
    function _unWrapETH(uint256 _amount) internal{
        require(
            IERC20(routerV2.WETH()).balanceOf(address(this)) >= _amount, 
            "DefiManagement: Insufficient amount to unwrap"
        );

        IWETH9(routerV2.WETH()).withdraw(_amount);
    }

// MasterChef Functions

    /**
        @notice Function to add liquidity in the mining program
        @dev Works with MasterChef V1
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool
    */
    function _depositInMasterChefV1(address _tokenA, address _tokenB) internal {
        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)) > 0, 
            "DefiManagement: Insufficient SLP Balance"
        );

        PoolMasterChefData storage poolData = poolDepositInMasterChefV1[factoryV2.getPair(_tokenA, _tokenB)];

        if(!poolData.previusDeposit){

            uint _pid;
            bool _pidExist;
            for(uint i = 0; i < masterChefV1.poolLength(); i++){
                if(factoryV2.getPair(_tokenA, _tokenB) == address(masterChefV1.poolInfo(i).lpToken)){
                    _pid = i;
                    _pidExist = true;
                    break;
                }
            }

            require(_pidExist, "DefiManagement: There is no pool registered for this pair in MasterChefV1");
            poolData.pid = _pid;
            poolData.previusDeposit = true;
        }

        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).approve(
                address(masterChefV1), 
                IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this))
            ),
            "DefiManagement: SLP approval error"
        );

        poolData.deposit += IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this));

        emit DepositInMasterChef(
            block.timestamp, 
            poolData.pid, 
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)), 
            "V1"
        );

        masterChefV1.deposit(
            poolData.pid, 
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this))
        );
    }

    /**
        @notice Function to withdraw liquidity in the mining program
        @dev Works with MasterChef V1
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool
    */
    function _withdrawInMasterChefV1(address _tokenA, address _tokenB) internal {
        require(
            poolDepositInMasterChefV1[factoryV2.getPair(_tokenA, _tokenB)].deposit > 0, 
            "DefiManagement: There are no deposits to withdraw in this pool"
        );

        PoolMasterChefData storage poolData = poolDepositInMasterChefV1[factoryV2.getPair(_tokenA, _tokenB)];

        masterChefV1.withdraw(
            poolData.pid, 
            poolData.deposit
        );

        emit WithdrawInMasterChef(
            block.timestamp, 
            poolData.pid, 
            poolData.deposit, 
            "V1"
        );

        poolData.deposit = 0;
    }

    /**
        @notice Function to add liquidity in the mining program
        @dev Works with MasterChef V2
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool
    */
    function _depositInMasterChefV2(address _tokenA, address _tokenB) internal {
        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)) > 0, 
            "DefiManagement: Insufficient SLP Balance"
        );

        PoolMasterChefData storage poolData = poolDepositInMasterChefV2[factoryV2.getPair(_tokenA, _tokenB)];

        if(!poolData.previusDeposit){

            uint _pid;
            bool _pidExist;
            for(uint i = 0; i < masterChefV2.poolLength(); i++){
                if(factoryV2.getPair(_tokenA, _tokenB) == address(masterChefV2.lpToken(i))){
                    _pid = i;
                    _pidExist = true;
                    break;
                }
            }

            require(_pidExist, "DefiManagement: There is no pool registered for this pair in MasterChefV2");
            poolData.pid = _pid;
            poolData.previusDeposit = true;
        }

        require(
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).approve(
                address(masterChefV2), 
                IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this))
            ),
            "DefiManagement: SLP approval error"
        );

        poolData.deposit += IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this));

        emit DepositInMasterChef(
            block.timestamp, 
            poolData.pid, 
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)), 
            "V2"
        );

        masterChefV2.deposit(
            poolData.pid, 
            IERC20(factoryV2.getPair(_tokenA, _tokenB)).balanceOf(address(this)),
            address(this)
        );
    }

    /**
        @notice Function to withdraw liquidity in the mining program
        @dev Works with MasterChef V2
        @param _tokenA address of the first token in the pool
        @param _tokenA address of the second token in the pool
    */
    function _withdrawInMasterChefV2(address _tokenA, address _tokenB) internal {
        require(
            poolDepositInMasterChefV2[factoryV2.getPair(_tokenA, _tokenB)].deposit > 0, 
            "DefiManagement: There are no deposits to withdraw in this pool"
        );

        PoolMasterChefData storage poolData = poolDepositInMasterChefV2[factoryV2.getPair(_tokenA, _tokenB)];

        masterChefV2.withdraw(
            poolData.pid, 
            poolData.deposit,
            address(this)
        );

        emit WithdrawInMasterChef(
            block.timestamp, 
            poolData.pid, 
            poolData.deposit, 
            "V2"
        );

        poolData.deposit = 0;
    }
}