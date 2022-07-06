// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISwapDataRequester {
    struct SwapDataParams {
        address fromTokenAddress;
        address toTokenAddress;
        uint256 amount;
        address fromAddress;
        uint256 slippage; // min 1 max 50
        address destReceiver;
        // uint256 fee;
        bool allowPartialFill;
    }

    struct CallbackParams {
        address callee;
        bytes4 functionSelector;
    }

    function aggregator() external view returns (address);

    function request(
        CallbackParams calldata callbackParams,
        SwapDataParams calldata swapParams
    ) external;
}
