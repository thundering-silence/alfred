// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title AaveV2's LendingPoolAddressesProvider contract
 **/
interface ILendingPoolAddressesProvider {

  function getMarketId() external view returns (string memory);

  function getAddress(bytes32 id) external view returns (address);

  function getLendingPool() external view returns (address);

  function getLendingPoolConfigurator() external view returns (address);

  function getLendingPoolCollateralManager() external view returns (address);

  function getPoolAdmin() external view returns (address);

  function getEmergencyAdmin() external view returns (address);

  function getPriceOracle() external view returns (address);

  function getLendingRateOracle() external view returns (address);
}
