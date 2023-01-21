// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8;

interface IMasterChefV1 {
    
    struct PoolInfo {
        IERC20 lpToken;           
        uint256 allocPoint;       
        uint256 lastRewardBlock;  
        uint256 accSushiPerShare; 
    }

    function deposit(uint256 _pid, uint256 _amount) external;
    function withdraw(uint256 _pid, uint256 _amount) external;
    function poolInfo(uint256 _pid) external view returns (IMasterChefV1.PoolInfo memory);
}