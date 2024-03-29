// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IMasterChefV2 {

    function poolLength() external view returns (uint256);
    function deposit(uint256 _pid, uint256 _amount, address _to) external;
    function withdraw(uint256 _pid, uint256 _amount, address _to) external;
    function lpToken(uint256 _pid) external view returns (IERC20);
}