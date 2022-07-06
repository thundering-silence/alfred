// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/delegates/IPoolDelegate.sol";

import "./Vault.sol";

contract LinkVault is Vault {
    using SafeERC20 for IERC20;
    using Address for address;

    constructor(
        string memory name_,
        address swapper_,
        address feesCollector_,
        address configProvider_
    ) Vault(name_, swapper_, feesCollector_, configProvider_) {}

    function _handleFees(uint256 amount) internal override returns (uint256) {
        uint256 devCut = amount > 10 ? amount / 10 : 0; // 10% to dev

        IERC20(_currentDebtAsset).transfer(_feesCollector, devCut);
        return amount - devCut;
    }
}
