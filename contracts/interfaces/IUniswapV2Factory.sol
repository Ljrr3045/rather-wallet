// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

interface IUniswapV2Factory {

    function getPair(address token0, address token1) external view returns (address);
}