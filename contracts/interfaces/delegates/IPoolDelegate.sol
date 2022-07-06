// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolDelegate {
    struct CallParams {
        address pool;
        address asset;
        uint256 amount;
        // address controller; // only needed for Comp
    }

    function supply(CallParams calldata params) external;

    function withdraw(CallParams calldata params) external;

    function borrow(CallParams calldata params) external;

    function repay(CallParams memory params) external;

    // function toggleMarket(CallParams calldata params, bool enter) external;

    function supplied(CallParams calldata params) external returns (uint256);

    function borrowed(CallParams memory params) external returns (uint256);
}
