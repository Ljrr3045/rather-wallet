//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "../interfaces/IWETH9.sol";

contract DefiManagement {

    IUniswapV2Router internal routerV2;
    IUniswapV2Factory internal factoryV2;

//Constructor

    /**
        @param _routerV2 Uniswap Router V2 address (or its forks)
    */
    constructor(
        address _routerV2
    ) {
        routerV2 = IUniswapV2Router(_routerV2);
        factoryV2 = IUniswapV2Factory(routerV2.factory());
    }

//Liquidity Functions

    function _addLiquidity(address _tokenA, address _tokenB) internal returns(uint _liquidity){
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

        (,, _liquidity) = routerV2.addLiquidity(
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
    }

    function _removeLiquidity(address _tokenA, address _tokenB) internal{
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

//Wraps Functions

    function _wrapETH() internal{
        require(msg.value > 0, "DefiManagement: Insufficient amount to wrap");

        IWETH9(routerV2.WETH()).deposit{value : msg.value}();
    }

    function _unWrapETH(uint256 _amount) internal{
        require(
            IERC20(routerV2.WETH()).balanceOf(address(this)) >= _amount, 
            "DefiManagement: Insufficient amount to unwrap"
        );

        IWETH9(routerV2.WETH()).withdraw(_amount);
    }
}