/ SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

interface IMasterChefV2 {

    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function lpToken(uint256 _pid) external view returns (IERC20);
}