// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IVaultGenerator {
    function owner() external view returns (address);

    function transferOwnership(address owner_) external;

    function createVault(string calldata name_) external;

    function getAccountVaults(address account)
        external
        view
        returns (address[] memory);
}
