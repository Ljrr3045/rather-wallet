//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./utils/DefiManagement.sol";

contract RatherWallet is DefiManagement, Ownable{

// Enums and Events

    enum MasterChefVersion{ V1, V2 }

    event DepositETH(uint256 indexed _date, uint256 _amount);
    event WithdrawETH(uint256 indexed _date, uint256 _amount);
    event DepositToken(uint256 indexed _date, address _token, uint256 _amount);
    event WithdrawToken(uint256 indexed _date, address _token, uint256 _amount);
    event InvestInMiningProgram(uint256 indexed _date, address _tokenA, address _tokenB, string _version);
    event WithdrawInMiningProgram(uint256 indexed _date, address _tokenA, address _tokenB, string _version);

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
    ) DefiManagement(
        _routerV2, 
        _masterChefV1, 
        _masterChefV2
    ) {}

// Mining program Functions

    function investInMiningProgram(
        address _tokenA, 
        address _tokenB, 
        MasterChefVersion _masterChefVersion
    ) external onlyOwner() {

        _addLiquidity(_tokenA, _tokenB);

        if(_masterChefVersion == MasterChefVersion.V1) 
            _depositInMasterChefV1(_tokenA, _tokenB);
        else
            _depositInMasterChefV2(_tokenA, _tokenB);

        emit InvestInMiningProgram(
            block.timestamp, 
            _tokenA, 
            _tokenB,
            _masterChefVersion == MasterChefVersion.V1 ? "V1" : "V2"
        );
    }

    function withdrawInMiningProgram(
        address _tokenA, 
        address _tokenB, 
        MasterChefVersion _masterChefVersion
    ) external onlyOwner() {

        if(_masterChefVersion == MasterChefVersion.V1)
            _withdrawInMasterChefV1(_tokenA, _tokenB);
        else
            _withdrawInMasterChefV2(_tokenA, _tokenB);

        _removeLiquidity(_tokenA, _tokenB);

        emit WithdrawInMiningProgram(
            block.timestamp, 
            _tokenA, 
            _tokenB,
            _masterChefVersion == MasterChefVersion.V1 ? "V1" : "V2"
        );
    }

// Deposit and withdraw Functions

    function depositToken(address _token, uint256 _amount) external onlyOwner() {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        emit DepositToken(block.timestamp, _token, _amount);
    }

    function withdrawToken(address _token, uint256 _amount) external onlyOwner() {
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount, 
            "RatherWallet: Insufficient amount to withdraw"
        );

        IERC20(_token).transfer(msg.sender, _amount);

        emit WithdrawToken(block.timestamp, _token, _amount);
    }

    function depositETH() external payable onlyOwner() {
        _wrapETH();

        emit DepositETH(block.timestamp, msg.value);
    }
    
    function withdrawETH(uint256 _amount) external onlyOwner() {
        _unWrapETH(_amount);

        (bool _sent,) = payable(msg.sender).call{value: _amount}("");
        require(_sent, "RatherWallet: Failed to send ETH");

        emit WithdrawETH(block.timestamp, _amount);
    }
    
// Receive Functions

    receive() external payable {
        _wrapETH();
    }
}
