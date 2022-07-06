// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/AaveV2/ILendingPool.sol";
import "../../interfaces/third-party/AaveV2/IProtocolDataProvider.sol";
import "../../interfaces/third-party/AaveV2/ILendingPoolAddressesProvider.sol";

import "../../interfaces/delegates/IPoolDelegate.sol";

/**
 * @notice Helper contract to interact with AaveV2' pool.
 * @dev This contract cannot hold any variables in storage as it must be called using delegatecall.
 */
contract AaveV2PoolDelegate is IPoolDelegate {
    function supply(IPoolDelegate.CallParams calldata params) external {
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
    }

    function repay(IPoolDelegate.CallParams calldata params) external {
        IERC20 token = IERC20(params.asset);
        token.approve(params.pool, params.amount);
        ILendingPool(params.pool).repay(
            params.asset,
            params.amount,
            2,
            address(this)
        );
    }

    function supplied(IPoolDelegate.CallParams calldata params)
        external
        view
        returns (uint256)
    {
        return IERC20(params.asset).balanceOf(address(this));
    }

    function borrowed(IPoolDelegate.CallParams calldata params)
        external
        view
        returns (uint256)
    {
        return IERC20(params.asset).balanceOf(address(this));
    }

    // function toggleMarket(IPoolDelegate.CallParams calldata params, bool enter)
    //     external
    // {}
}
