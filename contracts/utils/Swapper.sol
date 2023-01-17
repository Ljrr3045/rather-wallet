//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
    @title Swapper Contract
    @author ljrr3045
    @notice Contract that contains all the necessary functions to interact with UniswapV2 (or its forks).
    In the contract there are functions to swap tokens, add liquidity, etc.
*/

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../interfaces/IUniswapV2Router.sol";
import "../interfaces/IUniswapV2Pair.sol";
import "../interfaces/IUniswapV2Factory.sol";
import "./MathSqrt.sol";

contract Swapper is MathSqrt {

    address internal token1;
    address internal token2;
    address internal wMatic;
    IUniswapV2Router internal routerV2;
    IUniswapV2Factory internal factoryV2;

//Constructor

    /**
        @param _wMatic WMATIC address in the network used
        @param _token1 Address of the first token to use in the token pair
        @param _token2 Address of the second token to use in the token pair
        @param _routerV2 Uniswap Router V2 address (or its forks)
    */
    constructor(
        address _wMatic,
        address _token1,
        address _token2,
        address _routerV2
    ) {

        wMatic = _wMatic;
        token1 = _token1;
        token2 = _token2;

        routerV2 = IUniswapV2Router(_routerV2);
        factoryV2 = IUniswapV2Factory(routerV2.factory());
    }

//Liquidity Functions

    /**
        @notice Function to add liquidity to the pool, using MATIC.
        @dev This function swaps MATIC to Token1 and then calculates the optimal amount to swap from token1 to token2,
        finally adds liquidity to the pool.
        @dev Returns the amount of LP Token that was obtained in the operation.
    */
    function _addLiquidityWithMatic() internal returns(uint _liquidity){

        _swapMaticForToken(token1, msg.value);

        uint _amountOfToken1 = IERC20(token1).balanceOf(address(this));
        uint _amountForSwap = _swapAmount(token1, token2, _amountOfToken1);

        _swapTokenForToken(token1, token2, _amountForSwap);

        uint _amountDesiredToken1 = IERC20(token1).balanceOf(address(this));
        uint _amountDesiredToken2 = IERC20(token2).balanceOf(address(this));

        IERC20(token1).approve(address(routerV2), _amountDesiredToken1);
        IERC20(token2).approve(address(routerV2), _amountDesiredToken2);

        (,, _liquidity) = routerV2.addLiquidity(
            token1,
            token2,
            _amountDesiredToken1,
            _amountDesiredToken2,
            1,
            1,
            address(this),
            block.timestamp
        );

        uint _refoundToken1 = IERC20(token1).balanceOf(address(this));
        uint _refoundToken2 = IERC20(token2).balanceOf(address(this));


        if(_refoundToken1 > 0){
            IERC20(token1).transfer(msg.sender, _refoundToken1);
        }

        if(_refoundToken2 > 0){
            IERC20(token2).transfer(msg.sender, _refoundToken2);
        }

        if(address(this).balance > 0){

            (bool _success,) = msg.sender.call{ value: address(this).balance }("");
            require(_success, "Swapper: Refund failed");
        }
    }

    /**
        @notice Function to add liquidity to the pool, using WMATIC.
        @dev This function swaps WMATIC to Token1 and then calculates the optimal amount to swap from token1 to token2,
        finally adds liquidity to the pool.
        @dev Returns the amount of LP Token that was obtained in the operation.
    */
    function _addLiquidityWithWmatic(uint _amount) internal returns(uint _liquidity){

        IERC20(wMatic).transferFrom(msg.sender, address(this), _amount);

        _swapTokenForToken(wMatic, token1, _amount);

        uint _amountOfToken1 = IERC20(token1).balanceOf(address(this));
        uint _amountForSwap = _swapAmount(token1, token2, _amountOfToken1);

        _swapTokenForToken(token1, token2, _amountForSwap);

        uint _amountDesiredToken1 = IERC20(token1).balanceOf(address(this));
        uint _amountDesiredToken2 = IERC20(token2).balanceOf(address(this));

        IERC20(token1).approve(address(routerV2), _amountDesiredToken1);
        IERC20(token2).approve(address(routerV2), _amountDesiredToken2);

        (,, _liquidity) = routerV2.addLiquidity(
            token1,
            token2,
            _amountDesiredToken1,
            _amountDesiredToken2,
            1,
            1,
            address(this),
            block.timestamp
        );

        uint _refoundToken1 = IERC20(token1).balanceOf(address(this));
        uint _refoundToken2 = IERC20(token2).balanceOf(address(this));


        if(_refoundToken1 > 0){
            IERC20(token1).transfer(msg.sender, _refoundToken1);
        }

        if(_refoundToken2 > 0){
            IERC20(token2).transfer(msg.sender, _refoundToken2);
        }

        if(address(this).balance > 0){

            (bool _success,) = msg.sender.call{ value: address(this).balance }("");
            require(_success, "Swapper: Refund failed");
        }
    }

    /**
        @notice This function changes and removes funds from the pool (LP Token).
        @dev This function changes and returns all the money to the user in WMATIC.
    */
    function _removeLiquidityAndSwap(uint _amount) internal{

        IERC20(_getPair(token1, token2)).approve(address(routerV2), _amount);

        routerV2.removeLiquidity(
            token1,
            token2,
            _amount,
            1,
            1,
            address(this),
            block.timestamp
        );

        uint _balanceOfToken1 = IERC20(token1).balanceOf(address(this));
        uint _balanceOfToken2 = IERC20(token2).balanceOf(address(this));

        _swapTokenForToken(token1, wMatic, _balanceOfToken1);
        _swapTokenForToken(token2, wMatic, _balanceOfToken2);

        uint _refoundBalanceInWmatic = IERC20(wMatic).balanceOf(address(this));
        uint _refoundBalanceInToken1 = IERC20(token1).balanceOf(address(this));
        uint _refoundBalanceInToken2 = IERC20(token2).balanceOf(address(this));

        if(_refoundBalanceInWmatic > 0){
            IERC20(wMatic).transfer(msg.sender, _refoundBalanceInWmatic);
        }

        if(_refoundBalanceInToken1 > 0){
            IERC20(token1).transfer(msg.sender, _refoundBalanceInToken1);
        }

        if(_refoundBalanceInToken2 > 0){
            IERC20(token2).transfer(msg.sender, _refoundBalanceInToken2);
        }
    }

//Swapper Functions

    ///@dev Function to swap exactly MATIC for Token
    function _swapMaticForToken(address _token, uint _amount) private{

        address[] memory path = new address[](2);
        path = new address[](2);
        path[0] = wMatic;
        path[1] = _token;

        routerV2.swapExactETHForTokens {value : _amount}(
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    ///@dev Function to swap exactly Token for Token
    function _swapTokenForToken(address _tokenA, address _tokenB, uint _amount) private{

        IERC20(_tokenA).approve(address(routerV2), _amount);

        address[] memory path = new address[](2);
        path = new address[](2);
        path[0] = _tokenA;
        path[1] = _tokenB;

        routerV2.swapExactTokensForTokens(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

//Utility Functions

    ///@dev Returns the address of the LP Token contract of the token pair.
    function _getPair(address _tokenA, address _tokenB) internal view returns(address){
        return factoryV2.getPair(_tokenA, _tokenB);
    }

    ///@dev Returns the total amount to be swapped of TokenA to add liquidity in an equivalent way in the pool.
    function _swapAmount(address _tokenA, address _tokenB, uint _amount) private view returns(uint _swap){

        address _pair = _getPair(_tokenA, _tokenB);
        require(_pair != address(0), "Sapper: There is no token pair");

        (uint reserve0, uint reserve1,) = IUniswapV2Pair(_pair).getReserves();

        if (IUniswapV2Pair(_pair).token0() == _tokenA) {
            _swap = _getSwapAmount(reserve0, _amount);
        } else {
            _swap = _getSwapAmount(reserve1, _amount);
        }
    }
}