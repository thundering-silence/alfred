// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISwapExecutor {
    struct SwapDescription {
        address srcToken;
        address dstToken;
        address payable srcReceiver;
        address payable dstReceiver;
        uint256 amount;
        uint256 minReturnAmount;
        uint256 flags;
        bytes permit;
    }

    function executeSwap(bytes calldata data) external;

    function checkData(bytes calldata data) external;
}
