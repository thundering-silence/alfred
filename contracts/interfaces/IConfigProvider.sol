// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IConfigProvider {
    struct PoolConfig {
        address poolDelegate; // contract to which delegate calls for interacting with the pool.
        address rewardsDelegate; // contract to which delegate calls for harvesting rewards.
        bytes harvestCallData; // bytes calldata for rewardsDelegate.
    }

    function getPoolDelegate(address pool) external view returns (address);

    function getATokenFor(address pool, address asset) external view returns (address);

    function getVTokenFor(address pool, address asset) external view returns (address);

}
