// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../../interfaces/third-party/AaveV3/IPool.sol";
import "../../interfaces/third-party/AaveV3/IRewardsController.sol";
import "../../interfaces/third-party/AaveV3/IProtocolDataProvider.sol";

import "hardhat/console.sol";

/**
 * @notice Helper contract to interact with AaveV3 for rewards.
 * @dev This contract cannot hold any variables in storage as it must be called using delegatecall.
 */
contract Catalyst_AaveV3Rewards_Delegate {
    /**
     * @param controller - AaveV3 incentives controller
     * @param assets - list of a/s/vToken to withdraw rewards for
     */
    function harvestRewards(
        IRewardsController controller,
        address[] calldata assets
    ) external returns (address[] memory rewards, uint256[] memory amounts) {
        if (address(controller) != address(0)) {
            IRewardsController rewarder = IRewardsController(controller);
            return rewarder.claimAllRewardsToSelf(assets);
        }
    }
}
