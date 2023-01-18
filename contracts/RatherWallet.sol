//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./utils/DefiManagement.sol";

contract RatherWallet is DefiManagement{

    constructor(address _routerV2) DefiManagement(_routerV2) {}

    function depositToken(address _token, uint256 _amount) external {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    function depositETH() external payable{
        _wrapETH();
    }
    
    receive() external payable {
        _wrapETH();
    }
}
