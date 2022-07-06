// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

import "./interfaces/IConfigProvider.sol";

contract ConfigProvider is Ownable {
    mapping(address => IConfigProvider.PoolConfig) internal _poolsConfig;
    mapping(address => mapping(address=> address)) internal _aTokens;
    mapping(address => mapping(address=> address)) internal _vTokens;

    function getPoolDelegate(address pool) public view returns (address) {
        return _poolsConfig[pool].poolDelegate;
    }

    function getATokenFor(address pool, address asset) public view returns (address) {
        return _aTokens[pool][asset];
    }

    function getVTokenFor(address pool, address asset) public view returns (address) {
        return _vTokens[pool][asset];
    }

    function setPoolConfig(
        address pool,
        IConfigProvider.PoolConfig calldata config
    ) public onlyOwner {
        _poolsConfig[pool] = config;
    }

    function setATokenFor(address pool, address asset, address aToken) public onlyOwner {
        _aTokens[pool][asset] = aToken;
    }

    function setVTokenFor(address pool, address asset, address vToken) public onlyOwner {
        _vTokens[pool][asset] = vToken;
    }
}
