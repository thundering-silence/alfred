// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/AaveV2/ILendingPool.sol";
import "../../interfaces/third-party/AaveV2/IProtocolDataProvider.sol";
import "../../interfaces/third-party/AaveV2/ILendingPoolAddressesProvider.sol";

import "../../interfaces/delegates/IPoolDelegate.sol";

import "hardhat/console.sol";

/**
 * @notice Helper contract to interact with AaveV2' pool.
 * @dev This contract cannot hold any variables in storage as it must be called using delegatecall.
 */
contract AaveV2PoolDelegate is IPoolDelegate {
    function supply(IPoolDelegate.CallParams calldata params) external payable {
        require(msg.value == 0, "Delegate: 400");
        IERC20 token = IERC20(params.asset);
        token.approve(params.pool, params.amount);
        ILendingPool(params.pool).deposit(
            params.asset,
            params.amount,
            address(this),
            0
        );
    }

    function withdraw(IPoolDelegate.CallParams calldata params) external {
        // AaveV2 accepts type(uint).max as param to withdraw everything
        ILendingPool(params.pool).withdraw(
            params.asset,
            params.amount,
            address(this)
        );
    }

    function borrow(IPoolDelegate.CallParams calldata params) external {
        ILendingPool(params.pool).borrow(
            params.asset,
            params.amount,
            2,
            0,
            address(this)
        );
        IERC20(params.asset).transfer(msg.sender, params.amount);
    }

    function repay(IPoolDelegate.CallParams calldata params) external payable {
        require(msg.value == 0, "Delegate: 400");
        console.log("0");
        IERC20 token = IERC20(params.asset);
        token.approve(params.pool, params.amount);
        console.log("1");
        ILendingPool(params.pool).repay(
            params.asset,
            params.amount,
            2,
            address(this)
        );
        console.log("repayed %s to Aave", params.amount);
        console.log("2");
    }

    function supplied(address asset) external view returns (uint256) {
        return IERC20(asset).balanceOf(msg.sender);
    }

    function borrowed(address asset) external view returns (uint256) {
        console.log("borrowed=%s", IERC20(asset).balanceOf(msg.sender));
        return IERC20(asset).balanceOf(msg.sender);
    }
}
