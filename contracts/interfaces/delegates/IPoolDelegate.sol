// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPoolDelegate {
    struct CallParams {
        address pool;
        address asset;
        uint256 amount;
        address controller; // only needed for Comp forks
    }

    function supply(CallParams calldata params) external payable;

    function withdraw(CallParams calldata params) external;

    function borrow(CallParams calldata params) external;

    function repay(CallParams memory params) external payable;

    function supplied(address asset) external view returns (uint256);

    function borrowed(address asset) external view returns (uint256);
}
