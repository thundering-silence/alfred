// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/AaveV3/DataTypes.sol";
import "../../interfaces/third-party/AaveV3/IPool.sol";
import "../../interfaces/third-party/AaveV3/IRewardsController.sol";
import "../../interfaces/delegates/IPoolDelegate.sol";

import "hardhat/console.sol";

/**
 * @notice Helper contract to interact with AaveV3's pool.
 * @dev This contract cannot hold any variables in storage as it must be called using delegatecall.
 */
contract AaveV3PoolDelegate is IPoolDelegate {
    function supply(IPoolDelegate.CallParams calldata params) external {
        IERC20 token = IERC20(params.asset);
        token.approve(params.pool, params.amount);
        IPool(params.pool).supply(
            params.asset,
            params.amount,
            address(this),
            0
        );
    }

    function withdraw(IPoolDelegate.CallParams calldata params) external {
        IPool(params.pool).withdraw(params.asset, params.amount, address(this));
    }

    function borrow(IPoolDelegate.CallParams calldata params) external {
        IPool(params.pool).borrow(
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
        IPool(params.pool).repay(params.asset, params.amount, 2, address(this));
    }

    function supplied(IPoolDelegate.CallParams memory params)
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
        DataTypes.ReserveData memory data = IPool(params.pool).getReserveData(
            params.asset
        );
        return IERC20(data.variableDebtTokenAddress).balanceOf(address(this));
    }

    // function toggleMarket(IPoolDelegate.CallParams calldata params, bool enter)
    //     external
    // {}
}
