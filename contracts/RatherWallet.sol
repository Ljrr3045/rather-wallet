//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
    @title Rather Wallet
    @author ljrr3045
    @notice The main purpose of this contract is to serve as a smart wallet, where the user can store funds and in 
    turn invest in liquidity mining program.
*/

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

// Modifiers

    ///@dev verifies that the addresses to use are different to zero address
    modifier checkMultipleTokenAddress(address _tokenA, address _tokenB) {
        require(
            _tokenA != address(0) && _tokenB != address(0), 
            "RatherWallet: Token addresses equal to zero address"
        );
        _;
    }

    ///@dev Verify that the data used for the transfer is valid
    modifier checkTransactionData(address _token, uint256 _amount) {
        require(_token != address(0), "RatherWallet: Token address equal to zero address");
        require(_amount > 0, "RatherWallet: Transfer amount equal to zero");
        _;
    }

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

    /**
        @notice Function used to invest funds from the smart wallet in the liquidity mining program
        @dev only the owner can execute this action
        @param _tokenA address of the first token
        @param _tokenA address of the second token
        @param _masterChefVersion version of masterChef to use
    */
    function investInMiningProgram(
        address _tokenA, 
        address _tokenB, 
        MasterChefVersion _masterChefVersion
    ) external onlyOwner() checkMultipleTokenAddress(_tokenA, _tokenB){

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

    /**
        @notice Function used to withdraw funds from the smart wallet in the liquidity mining program
        @dev only the owner can execute this action
        @param _tokenA address of the first token
        @param _tokenA address of the second token
        @param _masterChefVersion version of masterChef to use
    */
    function withdrawInMiningProgram(
        address _tokenA, 
        address _tokenB, 
        MasterChefVersion _masterChefVersion
    ) external onlyOwner() checkMultipleTokenAddress(_tokenA, _tokenB){

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

    /**
        @notice Function used to deposit token to the smart wallet
        @dev only the owner can execute this action
        @param _token address of the token to deposit
        @param _amount token amount to deposit
    */
    function depositToken(
        address _token, 
        uint256 _amount
    ) external onlyOwner() checkTransactionData(_token, _amount){
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);

        emit DepositToken(block.timestamp, _token, _amount);
    }

    /**
        @notice Function used to withdraw token to the smart wallet
        @dev only the owner can execute this action
        @param _token address of the token to withdraw
        @param _amount token amount to withdraw
    */
    function withdrawToken(
        address _token, 
        uint256 _amount
    ) external onlyOwner() checkTransactionData(_token, _amount){
        require(
            IERC20(_token).balanceOf(address(this)) >= _amount, 
            "RatherWallet: Insufficient amount to withdraw"
        );

        IERC20(_token).transfer(msg.sender, _amount);

        emit WithdrawToken(block.timestamp, _token, _amount);
    }
    
    /**
        @notice Function used to deposit ETH to the smart wallet
        @dev only the owner can execute this action
        @dev function of type payable
    */
    function depositETH() external payable onlyOwner() {
        _wrapETH();

        emit DepositETH(block.timestamp, msg.value);
    }
    
    /**
        @notice Function used to withdraw ETH to the smart wallet
        @dev only the owner can execute this action
        @param _amount ETH amount to withdraw
    */
    function withdrawETH(uint256 _amount) external onlyOwner() {
        _unWrapETH(_amount);

        (bool _sent,) = payable(msg.sender).call{value: _amount}("");
        require(_sent, "RatherWallet: Failed to send ETH");

        emit WithdrawETH(block.timestamp, _amount);
    }
    
// Receive Function

    /**
        @notice Function that allows the smart wallet to receive direct transfers of ETH
        @dev if the transfer comes from an address other than the WETH contract, all the deposited ETH is 
        converted to WETH. This is done to more easily handle the movements of adding liquidity in pools
    */
    receive() external payable {

        if(msg.sender != routerV2.WETH()){
            _wrapETH();
        }
    }
}
