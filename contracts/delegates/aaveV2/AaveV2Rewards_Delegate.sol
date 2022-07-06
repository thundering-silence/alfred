// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../../interfaces/third-party/AaveV2/IAaveIncentivesController.sol";
import "../../interfaces/third-party/AaveV2/IProtocolDataProvider.sol";

import "hardhat/console.sol";

/**
 * @notice Helper contract to interact with AaveV2 for rewards.
 * @dev This contract cannot hold any variables in storage as it must be called using delegatecall.
 */
contract Catalyst_AaveV2Rewards_Delegate {
    /**
     * @param controller - AaveV2 incentives controller
     * @param assets - list of a/s/vToken to withdraw rewards for
     */
    function harvestRewards(
        IAaveIncentivesController controller,
        address[] memory assets
    ) external returns (address[] memory rewards, uint256[] memory amounts) {
        if (address(controller) != address(0)) {
            rewards[0] = controller.REWARD_TOKEN();
            amounts[0] = controller.claimRewards(
                assets,
                type(uint256).max,
                address(this)
            );
            console.log("step");
        }
    }
}
