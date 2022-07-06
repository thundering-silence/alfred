// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./delegates/IPoolDelegate.sol";
import "./swaps/ISwapExecutor.sol";
import "./IConfigProvider.sol";

interface IVault is IPoolDelegate, ISwapExecutor {
    function owner() external view returns (address);

    function transferOwnership(address owner_) external;

    function name() external view returns (string memory);

    function setName(string memory name_) external;

    function currentDebtPool() external view returns (address);

    function currentDebtAsset() external view returns (address);

    function getPoolConfig(address pool)
        external
        view
        returns (IConfigProvider.PoolConfig memory);

    function withdrawExcesses(IPoolDelegate.CallParams[] memory params)
        external;

    function getExcess(IPoolDelegate.CallParams memory params)
        external
        returns (uint256);

    function requestSwaps(address[] calldata assets) external;
}
