//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/DefiManagement.sol";

contract RatherWallet is DefiManagement, Ownable{

    constructor(address _routerV2) DefiManagement(_routerV2) {}

// Deposit and withdraw Functions

    function depositToken(address _token, uint256 _amount) external onlyOwner() {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
    }

    function withdrawToken(address _token, uint256 _amount) external onlyOwner() {
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount, 
            "RatherWallet: Insufficient amount to withdraw"
        );

        IERC20(_token).transfer(msg.sender, _amount);
    }

    function depositETH() external payable onlyOwner() {
        _wrapETH();
    }
    
    function withdrawETH(uint256 _amount) external onlyOwner() {
        _unWrapETH(_amount);

        (bool _sent,) = payable(msg.sender).call{value: _amount}("");
        require(_sent, "RatherWallet: Failed to send ETH");
    }
    
// Receive Functions

    receive() external payable {
        _wrapETH();
    }
}
